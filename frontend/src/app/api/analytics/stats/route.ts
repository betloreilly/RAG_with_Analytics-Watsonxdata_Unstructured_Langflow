import { NextResponse } from 'next/server'
import { getAnalyticsStats } from '@/lib/opensearch'

export async function GET() {
  try {
    const stats = await getAnalyticsStats()
    
    // Transform the data to match frontend expectations
    const transformed = {
      total_queries: stats.totalInteractions,
      avg_quality: stats.avgQuality,
      quality_distribution: stats.qualityDistribution, // Already an array of buckets
      needs_improvement_count: stats.needsImprovementCount,
      top_categories: stats.categoryDistribution.map((bucket: any) => ({
        name: bucket.key,
        count: bucket.doc_count
      })),
      recent_interactions: stats.recentInteractions,
      avg_latency: stats.avgLatency,
    }
    
    return NextResponse.json(transformed)
  } catch (error) {
    console.error('Analytics stats error:', error)
    return NextResponse.json(
      { error: 'Failed to fetch analytics stats' },
      { status: 500 }
    )
  }
}

