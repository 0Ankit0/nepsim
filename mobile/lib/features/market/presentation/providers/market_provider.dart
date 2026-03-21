// Re-export all Supabase-backed market providers from the data layer.
// Pages importing from here get the correct providers that use the
// new /market/nepse/... API endpoints backed by Supabase.
export '../../data/providers/market_provider.dart';
