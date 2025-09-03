import { Clock, CheckCircle, Heart } from 'lucide-react'

interface Feature {
  icon: React.ReactNode
  title: string
  description: string
}

const features: Feature[] = [
  {
    icon: <Clock className="w-10 h-10 text-white" />,
    title: "Real-time Search",
    description: "Search across multiple airlines with up-to-date pricing and availability."
  },
  {
    icon: <CheckCircle className="w-10 h-10 text-white" />,
    title: "Flexible Options",
    description: "Choose from one-way, round-trip, and multi-city travel options."
  },
  {
    icon: <Heart className="w-10 h-10 text-white" />,
    title: "Best Prices",
    description: "Compare prices across airlines to find the best deals for your trip."
  }
]

export const FeaturesSection: React.FC = () => {
  return (
    <div className="bg-white py-20">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-gray-800 mb-4">Why Choose FlightHub?</h2>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Discover the features that make us the preferred choice for finding your perfect flight
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <div 
              key={index} 
              className="text-center p-6 hover:transform hover:scale-105 transition-all duration-300"
            >
              <div className="w-20 h-20 bg-blue-600 rounded-full flex items-center justify-center mx-auto mb-6 shadow-lg">
                {feature.icon}
              </div>
              <h3 className="text-2xl font-bold text-gray-800 mb-4">{feature.title}</h3>
              <p className="text-gray-600 leading-relaxed">
                {feature.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
