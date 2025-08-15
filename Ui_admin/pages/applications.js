// pages/applications.js
import { useEffect, useMemo, useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/router'
import Layout from '../components/Layout'
import ApplicationsTable from '../components/ApplicationsTable'
import FilterPanel from '../components/FilterPanel'
import { supabase } from '../lib/supabaseClient'

export default function Applications() {
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const [errMsg, setErrMsg] = useState('')
  const [applications, setApplications] = useState([])
  const [filters, setFilters] = useState({
    search: '',
    status: 'all',
    type: 'all',
    dateRange: 'all',
  })

  // auth guard
  useEffect(() => {
    const authed = typeof window !== 'undefined' && localStorage.getItem('auth') === 'true'
    if (!authed) router.replace('/')
    else fetchData()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [router])

  // re-fetch when filters change
  useEffect(() => {
    if (typeof window !== 'undefined' && localStorage.getItem('auth') === 'true') {
      fetchData()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filters])

  const fetchData = async () => {
    setLoading(true)
    setErrMsg('')

    // Base query from the materialized/view you created earlier
    let query = supabase
      .from('vw_applications_list')
      .select('*')
      .order('submitted_at', { ascending: false })
      .limit(100)

    // Basic filters
    if (filters.status !== 'all') query = query.eq('status', filters.status)
    if (filters.type !== 'all') query = query.eq('business_type', filters.type)
    if (filters.search) query = query.ilike('business_name', `%${filters.search}%`)

    let { data, error } = await query

    // Helpful fallback if the view doesn't exist yet
    if (error && (error.code === '42P01' || /relation .* does not exist/i.test(error.message))) {
      setErrMsg(
        'The view "vw_applications_list" was not found. Create it in Supabase (or ask me for the SQL again).'
      )
      setApplications([])
      setLoading(false)
      return
    }

    if (error) {
      console.error(error)
      setErrMsg('Failed to load applications. Check your Supabase credentials and RLS policies.')
      setApplications([])
      setLoading(false)
      return
    }

    // Map into the table’s expected shape
    const rows =
      (data || []).map((r) => ({
        id: r.id,
        applicantName: r.applicant_name,
        businessName: r.business_name,
        businessType: r.business_type,
        status: r.status,
        submittedDate: r.submitted_at,
        assignee: r.assignee_name || 'Unassigned',
        aging: r.aging_days ?? 0,
      })) || []

    setApplications(rows)
    setLoading(false)
  }

  // Prepare CSV text in-memory (memoized)
  const csvText = useMemo(() => {
    const cols = [
      'Application ID',
      'Applicant Name',
      'Business Name',
      'Business Type',
      'Status',
      'Submitted Date',
      'Assignee',
      'Aging (days)',
    ]
    const rows = applications.map((a) => [
      a.id,
      a.applicantName,
      a.businessName,
      a.businessType,
      a.status,
      a.submittedDate ? new Date(a.submittedDate).toISOString() : '',
      a.assignee ?? '',
      String(a.aging ?? ''),
    ])
    return [cols, ...rows].map((r) => r.map(escapeCsv).join(',')).join('\n')
  }, [applications])

  const handleExportCsv = () => {
    const blob = new Blob([csvText], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `applications_${new Date().toISOString().slice(0, 10)}.csv`
    a.click()
    URL.revokeObjectURL(url)
  }

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
            <button className="btn btn-ghost" onClick={handleExportCsv}>
              <i className="fas fa-download" />
              Export CSV
            </button>

            {/* Replaces "Bulk Actions" with a real link to the create page */}
            <Link href="/applications/new" className="btn btn-primary">
              <i className="fas fa-plus" />
              New Application
            </Link>
          </div>
        </div>

        {errMsg && (
          <div className="error-banner" style={{ marginBottom: '1rem' }}>
            <i className="fas fa-exclamation-circle" />
            {errMsg}
          </div>
        )}

        <div className="applications-content">
          <FilterPanel filters={filters} setFilters={setFilters} />
          <ApplicationsTable applications={applications} />
        </div>
      </div>
    </Layout>
  )
}

/** utils */
function escapeCsv(value) {
  const s = value ?? ''
  const needsQuotes = /[",\n]/.test(s)
  const cleaned = String(s).replace(/"/g, '""')
  return needsQuotes ? `"${cleaned}"` : cleaned
}
