import { useState } from 'react'
import { useRouter } from 'next/router'
import Image from 'next/image'

export default function Login() {
  const [formData, setFormData] = useState({
    username: '',
    password: ''
  })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const router = useRouter()

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    setError('')
    
    // Simulate login
    setTimeout(() => {
      if (formData.username === 'admin' && formData.password === 'admin') {
        localStorage.setItem('auth', 'true')
        router.replace('/dashboard') 
      } else {
        setError('Invalid credentials')
      }
      setLoading(false)
    }, 1000)
  }

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    })
  }

  return (
    <div className="login-container">
      {/* Background Pattern */}
      <div className="login-bg-pattern"></div>
      
      {/* Header */}
      <nav className="login-nav">
        <div className="nav-container">
          <div className="nav-brand">
            <div className="logo-placeholder">
              <i className="fas fa-gateway"></i>
            </div>
            <span className="brand-text">Vyāpāra Gateway</span>
          </div>
          <div className="nav-links">
            <a href="#home">Home</a>
            <a href="#services">Services</a>
            <a href="#about">About</a>
            <a href="#contact">Contact</a>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <div className="login-content">
        <div className="login-card">
          <div className="login-header">
            <div className="login-logo">
              <div className="logo-circle">
                <i className="fas fa-shield-alt"></i>
              </div>
            </div>
            <h1>Admin Portal</h1>
            <p>Sign in to access the verification dashboard</p>
          </div>

          <form onSubmit={handleSubmit} className="login-form">
            {error && (
              <div className="error-banner">
                <i className="fas fa-exclamation-circle"></i>
                {error}
              </div>
            )}

            <div className="form-group">
              <label htmlFor="username">Username</label>
              <div className="input-wrapper">
                <i className="fas fa-user"></i>
                <input
                  type="text"
                  id="username"
                  name="username"
                  value={formData.username}
                  onChange={handleChange}
                  placeholder="Enter your username"
                  required
                />
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="password">Password</label>
              <div className="input-wrapper">
                <i className="fas fa-lock"></i>
                <input
                  type="password"
                  id="password"
                  name="password"
                  value={formData.password}
                  onChange={handleChange}
                  placeholder="Enter your password"
                  required
                />
              </div>
            </div>

            <button type="submit" className="login-btn" disabled={loading}>
              {loading ? (
                <>
                  <i className="fas fa-spinner fa-spin"></i>
                  Signing in...
                </>
              ) : (
                <>
                  <i className="fas fa-sign-in-alt"></i>
                  Sign In
                </>
              )}
            </button>

            <div className="login-footer">
              <a href="#forgot">Forgot your password?</a>
            </div>
          </form>
        </div>

        {/* Side Image */}
        <div className="login-image">
          <div className="image-content">
            <h2>Streamline Business Verification</h2>
            <p>Efficiently manage applications, verify documents, and approve registrations with our comprehensive admin platform.</p>
            <div className="feature-list">
              <div className="feature-item">
                <i className="fas fa-check-circle"></i>
                <span>Document Verification</span>
              </div>
              <div className="feature-item">
                <i className="fas fa-check-circle"></i>
                <span>Real-time Analytics</span>
              </div>
              <div className="feature-item">
                <i className="fas fa-check-circle"></i>
                <span>Secure Communication</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}