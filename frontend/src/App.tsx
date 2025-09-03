import { HeroSection } from './components/HeroSection'
import { FlightSearchPage } from './components/FlightSearchPage'
import { FeaturesSection } from './components/FeaturesSection'

function App() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <HeroSection />
      
      {/* Flight Search Page */}
      <FlightSearchPage />
      
      {/* Features Section */}
      <FeaturesSection />
    </div>
  )
}

export default App
