// pages/applications.js
import { useEffect, useState } from 'react'
import { useRouter } from 'next/router'
import Layout from '../components/Layout'
import ApplicationsTable from '../components/ApplicationsTable'
import FilterPanel from '../components/FilterPanel'
import { supabase } from '../lib/supabaseClient'

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
    const authed = typeof window !== 'undefined' && localStorage.getItem('auth') === 'true'
    if (!authed) {
      router.replace('/')
      return
    }
    fetchData()
  }, [router])

  const fetchData = async () => {
    setLoading(true)

    // Base query
    let query = supabase
      .from('vw_applications_list')
      .select('*')
      .order('submitted_at', { ascending: false })
      .limit(100)

    // Simple filter examples
    if (filters.status !== 'all') {
      query = query.eq('status', filters.status)
    }
    if (filters.type !== 'all') {
      query = query.eq('business_type', filters.type)
    }
    if (filters.search) {
      // crude search on id/name; for more advanced search make a tsvector column
      query = query.ilike('business_name', `%${filters.search}%`)
    }

    const { data, error } = await query
    if (error) {
      console.error(error)
      setApplications([])
    } else {
      // Map view rows to your table’s expected shape
      const rows = (data || []).map(r => ({
        id: r.id,
        applicantName: r.applicant_name,
        businessName: r.business_name,
        businessType: r.business_type,
        status: r.status,
        submittedDate: r.submitted_at,
        assignee: r.assignee_name || 'Unassigned',
        aging: r.aging_days ?? 0,
      }))
      setApplications(rows)
    }
    setLoading(false)
  }

  // re-fetch when filters change (basic)
  useEffect(() => {
    if (localStorage.getItem('auth') === 'true') fetchData()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filters])

  if (loading) {
    return (
      <div className="loading-screen">
        <div className="spinner" />
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
