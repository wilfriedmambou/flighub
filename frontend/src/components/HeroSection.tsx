export const HeroSection: React.FC = () => {
  return (
    <div className="relative overflow-hidden">
      {/* Background with airplane wing effect */}
      <div className="absolute inset-0 bg-gradient-to-br from-blue-400 via-blue-500 to-blue-600">
        <div className="absolute top-20 right-10 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-20 left-10 w-48 h-48 bg-white/5 rounded-full blur-2xl"></div>
      </div>
      
      {/* Content */}
      <div className="relative z-10 container mx-auto px-4 py-16">
        <div className="text-center text-white mb-12 animate-fade-in">
          <h1 className="text-5xl font-bold mb-4 leading-tight">
            Find Your Perfect Flight
          </h1>
          <p className="text-xl opacity-90 max-w-3xl mx-auto leading-relaxed">
            Search and compare flights from multiple airlines. Build your ideal trip with one-way or round-trip options.
          </p>
        </div>
      </div>
    </div>
  )
}
