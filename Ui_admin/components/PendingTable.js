export default function PendingTable() {
  const pendingApplications = [
    {
      id: 'APP-2024-001',
      username: 'johnsilva',
      email: 'john.silva@email.com',
      signupDate: '2024-08-10',
      status: 'Pending'
    },
    {
      id: 'APP-2024-002',
      username: 'maryfernando',
      email: 'mary.fernando@email.com',
      signupDate: '2024-08-12',
      status: 'Pending'
    },
    {
      id: 'APP-2024-003',
      username: 'davidperera',
      email: 'david.perera@email.com',
      signupDate: '2024-08-08',
      status: 'Under Review'
    }
  ]

  return (
    <div className="table-container">
      <div className="table-wrapper">
        <table className="data-table">
          <thead>
            <tr>
              <th>Username</th>
              <th>Email</th>
              <th>Signup Date</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {pendingApplications.map((app) => (
              <tr key={app.id}>
                <td>
                  <div className="user-cell">
                    <div className="user-avatar small">
                      <i className="fas fa-user"></i>
                    </div>
                    <span>{app.username}</span>
                  </div>
                </td>
                <td>{app.email}</td>
                <td>{new Date(app.signupDate).toLocaleDateString()}</td>
                <td>
                  <span className={`status-badge ${app.status === 'Pending' ? 'pending' : 'review'}`}>
                    {app.status}
                  </span>
                </td>
                <td>
                  <div className="action-buttons">
                    <button className="btn btn-sm btn-primary">Approve</button>
                    <button className="btn btn-sm btn-ghost">View</button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}