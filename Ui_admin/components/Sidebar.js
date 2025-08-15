// File: components/Sidebar.js
import { useState } from 'react'
import { useRouter } from 'next/router'
import Link from 'next/link'

export default function Sidebar({ isOpen }) {
  const router = useRouter()
  const [activeSubmenu, setActiveSubmenu] = useState(null)

  const menuItems = [
    { name: 'Dashboard', icon: 'fas fa-chart-bar', path: '/dashboard', badge: null },
    { name: 'Applications', icon: 'fas fa-file-alt', path: '/applications', badge: '24' },
    {
      name: 'Users',
      icon: 'fas fa-users',
      path: '/users',
      submenu: [
        { name: 'Pending Sign-ups', path: '/users/pending' },
        { name: 'All Users', path: '/users/all' }
      ]
    },
    { name: 'Reports', icon: 'fas fa-chart-line', path: '/reports' },
    { name: 'Settings', icon: 'fas fa-cog', path: '/settings' },
    { name: 'Help & Feedback', icon: 'fas fa-question-circle', path: '/help' }
  ]

  const handleLogout = () => {
    localStorage.removeItem('auth')
    router.push('/')
  }

  return (
    <div className={`sidebar ${isOpen ? 'open' : 'closed'}`}>
      <div className="sidebar-header">
        <div className="logo-container">
          <div className="logo-icon">
            <i className="fas fa-diagram-project"></i>
          </div>
          {isOpen && (
            <div className="logo-text">
              <h3>Vyāpāra Gateway</h3>
              <span>Admin Portal</span>
            </div>
          )}
        </div>
      </div>

      <nav className="sidebar-nav">
        {menuItems.map((item, index) => (
          <div key={index} className="nav-item">
            {item.submenu ? (
              <>
                <button
                  className={`nav-link ${activeSubmenu === item.name ? 'active' : ''}`}
                  onClick={() => setActiveSubmenu(activeSubmenu === item.name ? null : item.name)}
                >
                  <i className={item.icon}></i>
                  {isOpen && <span>{item.name}</span>}
                  {isOpen && <i className="fas fa-chevron-down submenu-arrow"></i>}
                  {item.badge && <span className="nav-badge">{item.badge}</span>}
                </button>

                {isOpen && activeSubmenu === item.name && (
                  <div className="submenu">
                    {item.submenu.map((subitem, subindex) => (
                      <Link
                        key={subindex}
                        href={subitem.path}
                        className={`submenu-link ${router.pathname === subitem.path ? 'active' : ''}`}
                      >
                        {subitem.name}
                      </Link>
                    ))}
                  </div>
                )}
              </>
            ) : (
              <Link
                href={item.path}
                className={`nav-link ${router.pathname === item.path ? 'active' : ''}`}
              >
                <i className={item.icon}></i>
                {isOpen && <span>{item.name}</span>}
                {item.badge && <span className="nav-badge">{item.badge}</span>}
              </Link>
            )}
          </div>
        ))}
      </nav>

      <div className="sidebar-footer">
        <div className="user-profile">
          <div className="user-avatar">
            <i className="fas fa-user-circle"></i>
          </div>
          {isOpen && (
            <div className="user-info">
              <h4>Admin User</h4>
              <p>Super Administrator</p>
            </div>
          )}
        </div>
        <button className="logout-btn" onClick={handleLogout}>
          <i className="fas fa-sign-out-alt"></i>
          {isOpen && <span>Logout</span>}
        </button>
      </div>
    </div>
  )
}
