export default function AuditLog({ applicationId }) {
  const auditEntries = [
    {
      id: 1,
      action: 'Application Submitted',
      actor: 'John Silva',
      timestamp: '2024-08-10T10:00:00Z',
      details: 'Initial application submission',
      icon: 'fas fa-file-plus'
    },
    {
      id: 2,
      action: 'Document Uploaded',
      actor: 'John Silva',
      timestamp: '2024-08-10T10:15:00Z',
      details: 'Business Plan document uploaded',
      icon: 'fas fa-upload'
    },
    {
      id: 3,
      action: 'Application Viewed',
      actor: 'Sarah Johnson',
      timestamp: '2024-08-11T09:30:00Z',
      details: 'Application opened for review',
      icon: 'fas fa-eye'
    },
    {
      id: 4,
      action: 'Document Reviewed',
      actor: 'Sarah Johnson',
      timestamp: '2024-08-11T14:30:00Z',
      details: 'Business Plan marked as approved',
      icon: 'fas fa-check'
    },
    {
      id: 5,
      action: 'Message Sent',
      actor: 'Sarah Johnson',
      timestamp: '2024-08-11T14:35:00Z',
      details: 'Requested clearer NIC copy',
      icon: 'fas fa-envelope'
    },
    {
      id: 6,
      action: 'Document Re-uploaded',
      actor: 'John Silva',
      timestamp: '2024-08-12T09:15:00Z',
      details: 'New NIC copy uploaded',
      icon: 'fas fa-sync'
    }
  ]

  return (
    <div className="audit-log">
      <div className="audit-header">
        <h3>Audit Trail</h3>
        <div className="audit-filters">
          <select className="audit-filter">
            <option value="all">All Actions</option>
            <option value="user">User Actions</option>
            <option value="admin">Admin Actions</option>
            <option value="system">System Events</option>
          </select>
        </div>
      </div>

      <div className="audit-timeline">
        {auditEntries.map((entry) => (
          <div key={entry.id} className="audit-entry">
            <div className="audit-icon">
              <i className={entry.icon}></i>
            </div>
            <div className="audit-content">
              <div className="audit-action">
                <strong>{entry.action}</strong>
                <span className="audit-actor">by {entry.actor}</span>
              </div>
              <div className="audit-details">{entry.details}</div>
              <div className="audit-timestamp">
                {new Date(entry.timestamp).toLocaleString()}
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="audit-footer">
        <button className="btn btn-ghost">
          <i className="fas fa-download"></i>
          Export Audit Log
        </button>
      </div>
    </div>
  )
}
