import { useEffect, useState } from 'react'
import { useRouter } from 'next/router'
import Layout from '../../components/Layout'
import ApplicationSnapshot from '../../components/ApplicationSnapshot'
import StatusStepper from '../../components/StatusStepper'
import DocumentsPanel from '../../components/DocumentsPanel'
import IdentityPanel from '../../components/IdentityPanel'
import DecisionPanel from '../../components/DecisionPanel'
import SecureMessages from '../../components/SecureMessages'
import AuditLog from '../../components/AuditLog'

export default function ApplicationDetail() {
  const router = useRouter()
  const { id } = router.query
  const [loading, setLoading] = useState(true)
  const [application, setApplication] = useState(null)
  const [activeTab, setActiveTab] = useState('overview')

  useEffect(() => {
    const auth = localStorage.getItem('auth')
    if (!auth) {
      router.push('/')
      return
    }

    if (id) {
      // Mock application data
      setApplication({
        id: id,
        applicantName: 'John Silva',
        email: 'john.silva@email.com',
        phone: '+94771234567',
        businessName: 'Silva Traders',
        businessType: 'Sole Proprietorship',
        submittedDate: '2024-08-10',
        currentStage: 'In Review',
        assignee: 'Sarah Johnson',
        documents: [
          { name: 'Business Plan', status: 'Approved', uploadDate: '2024-08-10' },
          { name: 'Financial Projections', status: 'Pending', uploadDate: '2024-08-10' },
          { name: 'Legal Agreements', status: 'Rejected', uploadDate: '2024-08-09' }
        ],
        identity: {
          method: 'NIC',
          nicNumber: '123456789V',
          nameOnDoc: 'John Silva',
          dateOfBirth: '1985-05-15',
          issueDate: '2020-06-01',
          status: 'Pending'
        }
      })
      setLoading(false)
    }
  }, [id, router])

  if (loading) {
    return (
      <div className="loading-screen">
        <div className="spinner"></div>
      </div>
    )
  }

  if (!application) {
    return <div>Application not found</div>
  }

  return (
    <Layout>
      <div className="application-detail-container">
        <div className="application-header">
          <div className="header-content">
            <div className="breadcrumb">
              <a href="/applications">Applications</a>
              <i className="fas fa-chevron-right"></i>
              <span>{application.id}</span>
            </div>
            <h1>{application.businessName}</h1>
            <p>{application.applicantName} • {application.businessType}</p>
          </div>
          <div className="header-actions">
            <button className="btn btn-ghost">
              <i className="fas fa-print"></i>
              Print
            </button>
            <button className="btn btn-ghost">
              <i className="fas fa-share"></i>
              Share
            </button>
          </div>
        </div>

        {/* Application Snapshot */}
        <ApplicationSnapshot application={application} />

        {/* Status Stepper */}
        <div className="application-card">
          <div className="card-header">
            <h3>Application Progress</h3>
          </div>
          <StatusStepper currentStage={application.currentStage} />
        </div>

        {/* Tabbed Content */}
        <div className="application-tabs">
          <div className="tab-nav">
            <button 
              className={activeTab === 'overview' ? 'tab-btn active' : 'tab-btn'}
              onClick={() => setActiveTab('overview')}
            >
              <i className="fas fa-eye"></i>
              Overview
            </button>
            <button 
              className={activeTab === 'identity' ? 'tab-btn active' : 'tab-btn'}
              onClick={() => setActiveTab('identity')}
            >
              <i className="fas fa-id-card"></i>
              Identity
            </button>
            <button 
              className={activeTab === 'documents' ? 'tab-btn active' : 'tab-btn'}
              onClick={() => setActiveTab('documents')}
            >
              <i className="fas fa-folder"></i>
              Documents
            </button>
            <button 
              className={activeTab === 'messages' ? 'tab-btn active' : 'tab-btn'}
              onClick={() => setActiveTab('messages')}
            >
              <i className="fas fa-comments"></i>
              Messages
            </button>
            <button 
              className={activeTab === 'audit' ? 'tab-btn active' : 'tab-btn'}
              onClick={() => setActiveTab('audit')}
            >
              <i className="fas fa-history"></i>
              Audit
            </button>
          </div>

          <div className="tab-content">
            {activeTab === 'overview' && (
              <div className="tab-grid">
                <DocumentsPanel documents={application.documents} />
                <DecisionPanel applicationId={application.id} />
              </div>
            )}
            {activeTab === 'identity' && <IdentityPanel identity={application.identity} />}
            {activeTab === 'documents' && <DocumentsPanel documents={application.documents} detailed={true} />}
            {activeTab === 'messages' && <SecureMessages applicationId={application.id} />}
            {activeTab === 'audit' && <AuditLog applicationId={application.id} />}
          </div>
        </div>
      </div>
    </Layout>
  )
}