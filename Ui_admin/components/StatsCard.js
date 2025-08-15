export default function StatsCard({ title, value, change, trend, icon, color }) {
  return (
    <div className={`stats-card ${color}`}>
      <div className="stats-content">
        <div className="stats-header">
          <h3>{title}</h3>
          <div className={`stats-icon ${color}`}>
            <i className={icon}></i>
          </div>
        </div>
        <div className="stats-value">
          <span className="value">{value}</span>
          <div className={`stats-change ${trend}`}>
            <i className={trend === 'up' ? 'fas fa-arrow-up' : 'fas fa-arrow-down'}></i>
            {change}
          </div>
        </div>
      </div>
    </div>
  )
}