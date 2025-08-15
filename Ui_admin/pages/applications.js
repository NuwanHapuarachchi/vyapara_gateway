import { useEffect, useState } from 'react'
import { useRouter } from 'next/router'
import Layout from '../components/Layout'
import ApplicationsTable from '../components/ApplicationsTable'
import FilterPanel from '../components/FilterPanel'

export default function Applications() {
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const [applications, setApplications] = useState([])
  const [filters, setFilters] = useState({
    search: '',
    status: 'all',
    type: 'all',
    dateRange: 'all'
  })

  useEffect(() => {
    const auth = localStorage.getItem('auth')
    if (!auth) {
      router.push('/')
      return
    }
    
    // Mock data
    setApplications([
      {
        id: 'APP-2024-001',
        applicantName: 'John Silva',
        businessName: 'Silva Traders',
        businessType: 'Sole Proprietorship',
        status: 'Pending',
        submittedDate: '2024-08-10',
        assignee: 'Sarah Johnson',
        aging: 5
      },
      {
        id: 'APP-2024-002',
        applicantName: 'Mary Fernando',
        businessName: 'Fernando & Co',
        businessType: 'Partnership',
        status: 'In Review',
        submittedDate: '2024-08-12',
        assignee: 'Mike Chen',
        aging: 3
      },
      {
        id: 'APP-2024-003',
        applicantName: 'David Perera',
        businessName: 'Tech Innovations LLC',
        businessType: 'LLC',
        status: 'Approved',
        submittedDate: '2024-08-08',
        assignee: 'Sarah Johnson',
        aging: 7
      }
    ])
    setLoading(false)
  }, [router])

  if (loading) {
    return (
      <div className="loading-screen">
        <div className="spinner"></div>
      </div>
    )
  }

  return (
    <Layout>
      <div className="applications-container">
        <div className="applications-header">
          <div className="header-content">
            <h1>Applications</h1>
            <p>Manage and review business registration applications</p>
          </div>
          <div className="header-actions">
            <button className="btn btn-ghost">
              <i className="fas fa-download"></i>
              Export CSV
            </button>
            <button className="btn btn-primary">
              <i className="fas fa-plus"></i>
              Bulk Actions
            </button>
          </div>
        </div>

        <div className="applications-content">
          <FilterPanel filters={filters} setFilters={setFilters} />
          <ApplicationsTable applications={applications} />
        </div>
      </div>
    </Layout>
  )
}