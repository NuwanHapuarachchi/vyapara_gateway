# Supabase Storage Buckets Configuration

## Required Storage Buckets for Vyāpāra Gateway

### 1. **business-documents** (Private)
**Purpose**: Store all business registration documents uploaded by users
**Configuration**:
- **Access**: Private (authenticated users only)
- **File Size Limit**: 5MB per file
- **Allowed File Types**: PDF, JPG, PNG
- **RLS Policy**: Users can only access documents for businesses they own/are partners in

**Folder Structure**:
```
business-documents/
├── {business_id}/
│   ├── application_forms/
│   ├── identity_documents/
│   ├── business_premises/
│   ├── certificates/
│   ├── partnership_agreements/
│   └── versions/
│       ├── {document_id}_v1.pdf
│       ├── {document_id}_v2.pdf
│       └── ...
```

**RLS Policy SQL**:
```sql
-- Allow users to upload documents for their own businesses
CREATE POLICY "Users can upload business documents" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'business-documents' AND 
  auth.uid()::text = (storage.foldername(name))[1] OR
  auth.uid() IN (
    SELECT owner_id FROM businesses WHERE id::text = (storage.foldername(name))[1]
    UNION
    SELECT partner_id FROM business_partners 
    WHERE business_id::text = (storage.foldername(name))[1]
  )
);

-- Allow users to view documents for their businesses
CREATE POLICY "Users can view business documents" ON storage.objects
FOR SELECT USING (
  bucket_id = 'business-documents' AND (
    auth.uid() IN (
      SELECT owner_id FROM businesses WHERE id::text = (storage.foldername(name))[1]
      UNION
      SELECT partner_id FROM business_partners 
      WHERE business_id::text = (storage.foldername(name))[1]
    )
  )
);
```

---

### 2. **document-templates** (Public)
**Purpose**: Store sample documents and templates that users can download as references
**Configuration**:
- **Access**: Public (anyone can read)
- **File Size Limit**: 10MB per file
- **Allowed File Types**: PDF, DOC, DOCX
- **RLS Policy**: Public read, admin write only

**Folder Structure**:
```
document-templates/
├── sole_proprietorship/
│   ├── application_form_sample.pdf
│   ├── grama_niladhari_report_template.pdf
│   └── trade_permit_sample.pdf
├── partnership/
│   ├── partnership_agreement_template.pdf
│   ├── application_form_sample.pdf
│   └── ...
├── private_limited_company/
│   ├── form_1_sample.pdf
│   ├── form_18_sample.pdf
│   ├── articles_of_association_template.pdf
│   └── ...
└── public_limited_company/
    └── ...
```

---

### 3. **profile-images** (Private)
**Purpose**: Store user profile pictures
**Configuration**:
- **Access**: Private (authenticated users only)
- **File Size Limit**: 2MB per file
- **Allowed File Types**: JPG, PNG, WEBP
- **RLS Policy**: Users can only access their own profile images

**Folder Structure**:
```
profile-images/
├── {user_id}/
│   ├── avatar.jpg
│   └── thumbnail.jpg
```

**RLS Policy SQL**:
```sql
-- Users can manage their own profile images
CREATE POLICY "Users can manage own profile images" ON storage.objects
FOR ALL USING (
  bucket_id = 'profile-images' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);
```

---

### 4. **service-provider-docs** (Private)
**Purpose**: Store verification documents for lawyers and mentors
**Configuration**:
- **Access**: Private (service providers and admins only)
- **File Size Limit**: 5MB per file
- **Allowed File Types**: PDF, JPG, PNG
- **RLS Policy**: Service providers can upload, admins can view all

**Folder Structure**:
```
service-provider-docs/
├── {provider_id}/
│   ├── license/
│   ├── qualifications/
│   ├── experience_certificates/
│   └── identity_documents/
```

**RLS Policy SQL**:
```sql
-- Service providers can upload their own documents
CREATE POLICY "Service providers can upload documents" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'service-provider-docs' AND 
  auth.uid()::text = (storage.foldername(name))[1] AND
  auth.uid() IN (SELECT user_id FROM service_providers)
);

-- Admins and the service provider can view the documents
CREATE POLICY "Admins and providers can view documents" ON storage.objects
FOR SELECT USING (
  bucket_id = 'service-provider-docs' AND (
    auth.uid()::text = (storage.foldername(name))[1] OR
    auth.uid() IN (SELECT id FROM user_profiles WHERE role = 'admin')
  )
);
```

---

### 5. **system-assets** (Public)
**Purpose**: Store app logos, icons, banners, and other public assets
**Configuration**:
- **Access**: Public (anyone can read)
- **File Size Limit**: 5MB per file
- **Allowed File Types**: JPG, PNG, SVG, WEBP
- **RLS Policy**: Public read, admin write only

**Folder Structure**:
```
system-assets/
├── logos/
├── icons/
├── banners/
├── government_office_logos/
└── bank_logos/
```

---

## Bucket Creation Commands

```sql
-- 1. Business Documents (Private)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'business-documents', 
  'business-documents', 
  false, 
  5242880, -- 5MB in bytes
  ARRAY['application/pdf', 'image/jpeg', 'image/png']
);

-- 2. Document Templates (Public)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'document-templates', 
  'document-templates', 
  true, 
  10485760, -- 10MB in bytes
  ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
);

-- 3. Profile Images (Private)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'profile-images', 
  'profile-images', 
  false, 
  2097152, -- 2MB in bytes
  ARRAY['image/jpeg', 'image/png', 'image/webp']
);

-- 4. Service Provider Documents (Private)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'service-provider-docs', 
  'service-provider-docs', 
  false, 
  5242880, -- 5MB in bytes
  ARRAY['application/pdf', 'image/jpeg', 'image/png']
);

-- 5. System Assets (Public)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'system-assets', 
  'system-assets', 
  true, 
  5242880, -- 5MB in bytes
  ARRAY['image/jpeg', 'image/png', 'image/svg+xml', 'image/webp']
);
```

## Flutter Integration Examples

### Upload Business Document
```dart
Future<String?> uploadBusinessDocument(
  String businessId,
  String documentType,
  File file,
  int version,
) async {
  final fileName = '${uuid.v4()}_v$version.${file.path.split('.').last}';
  final filePath = '$businessId/$documentType/$fileName';
  
  try {
    await Supabase.instance.client.storage
        .from('business-documents')
        .upload(filePath, file);
    
    return filePath;
  } catch (e) {
    print('Upload failed: $e');
    return null;
  }
}
```

### Get Document URL
```dart
String getDocumentUrl(String filePath) {
  return Supabase.instance.client.storage
      .from('business-documents')
      .getPublicUrl(filePath);
}
```

### Upload Profile Image
```dart
Future<String?> uploadProfileImage(File imageFile) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;
  
  final fileName = 'avatar.${imageFile.path.split('.').last}';
  final filePath = '$userId/$fileName';
  
  try {
    await Supabase.instance.client.storage
        .from('profile-images')
        .upload(filePath, imageFile, fileOptions: const FileOptions(upsert: true));
    
    return filePath;
  } catch (e) {
    print('Profile image upload failed: $e');
    return null;
  }
}
```

## Security Considerations

1. **File Size Validation**: Always validate file sizes on both client and server
2. **File Type Validation**: Check MIME types and file extensions
3. **Virus Scanning**: Consider integrating virus scanning for uploaded files
4. **Rate Limiting**: Implement upload rate limiting to prevent abuse
5. **Backup Strategy**: Regular backups of critical business documents

## Monitoring & Maintenance

1. **Storage Usage**: Monitor bucket sizes and implement cleanup policies
2. **Failed Uploads**: Track and retry failed uploads
3. **Access Logs**: Monitor access patterns for security
4. **Document Retention**: Implement retention policies for old documents
