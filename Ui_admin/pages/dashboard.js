// pages/dashboard.js
import { useEffect, useState } from 'react'
import { useRouter } from 'next/router'
import Link from 'next/link'
import { supabase } from '../lib/supabaseClient'

import Layout from '../components/Layout'
import StatsCard from '../components/StatsCard'
import PendingTable from '../components/PendingTable'
import VerificationPipeline from '../components/VerificationPipeline'
import RecentActivity from '../components/RecentActivity'

export default function Dashboard() {
  const router = useRouter()
  const [ready, setReady] = useState(false)

  useEffect(() => {
    const authed = typeof window !== 'undefined' && localStorage.getItem('auth') === 'true'
    if (!authed) router.replace('/') // bounce to login if not authed
    else setReady(true)
  }, [router])

  if (!ready) {
    return (
      <div className="loading-screen">
        <div className="spinner" />
      </div>
    )
  }

  const statsData = [
    { title: 'Pending Applications', value: '24', change: '+12%', trend: 'up', icon: 'fa-solid fa-clock', color: 'orange' },
    { title: 'Approved Today', value: '18', change: '+8%', trend: 'up', icon: 'fa-solid fa-circle-check', color: 'green' },
    { title: 'In Review', value: '31', change: '-5%', trend: 'down', icon: 'fa-solid fa-eye', color: 'blue' },
    { title: 'Total Users', value: '1,247', change: '+23%', trend: 'up', icon: 'fa-solid fa-users', color: 'purple' }
  ]

  return (
    <Layout>
      <div className="dashboard-container">
        <div className="dashboard-header">
          <div className="header-content">
            <h1>Dashboard</h1>
            <p>Welcome back! Here's what's happening with your applications.</p>
          </div>
          <div className="header-actions">
            <button className="btn btn-primary">
              <i className="fa-solid fa-plus"></i>
              New Application
            </button>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="stats-grid">
          {statsData.map((s, i) => <StatsCard key={i} {...s} />)}
        </div>

        {/* Main Content Grid */}
        <div className="dashboard-grid">
          {/* Verification Pipeline */}
          <div className="dashboard-card pipeline-card">
            <div className="card-header">
              <h3>Verification Pipeline</h3>
              <button className="btn btn-ghost btn-sm">
                <i className="fa-solid fa-expand"></i>
              </button>
            </div>
            <VerificationPipeline />
          </div>

          {/* Pending Applications */}
          <div className="dashboard-card">
            <div className="card-header">
              <h3>Pending Sign-ups</h3>
              <Link href="/applications" className="btn btn-ghost btn-sm">
                View All <i className="fa-solid fa-arrow-right"></i>
              </Link>
            </div>
            <PendingTable />
          </div>

          {/* Recent Activity */}
          <div className="dashboard-card activity-card">
            <div className="card-header">
              <h3>Recent Activity</h3>
              <button className="btn btn-ghost btn-sm">
                <i className="fa-solid fa-rotate"></i>
              </button>
            </div>
            <RecentActivity />
          </div>

          {/* SLA Alerts */}
          <div className="dashboard-card alerts-card">
            <div className="card-header">
              <h3>SLA Alerts</h3>
              <span className="alert-badge">3</span>
            </div>
            <div className="alerts-list">
              <div className="alert-item critical">
                <div className="alert-icon">
                  <i className="fa-solid fa-triangle-exclamation"></i>
                </div>
                <div className="alert-content">
                  <h4>Critical Delay</h4>
                  <p>APP-2024-001 pending for 72+ hours</p>
                  <span className="alert-time">3 days ago</span>
                </div>
              </div>
              <div className="alert-item warning">
                <div className="alert-icon">
                  <i className="fa-solid fa-clock"></i>
                </div>
                <div className="alert-content">
                  <h4>Review Needed</h4>
                  <p>5 applications require senior review</p>
                  <span className="alert-time">1 day ago</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  )
}
