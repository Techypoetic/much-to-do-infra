output "cloudfront_url" {
  description = "Live frontend URL — submit this as your Live Frontend URL"
  value       = "https://${module.frontend.cloudfront_domain_name}"
}

output "alb_dns_name" {
  description = "Backend API endpoint (proxied through CloudFront at /api/*)"
  value       = module.compute.alb_dns_name
}

output "s3_bucket_name" {
  description = "S3 bucket for frontend assets"
  value       = module.frontend.s3_bucket_name
}

output "cloudfront_distribution_id" {
  description = "For cache invalidation in CI/CD — add to GitHub Secrets"
  value       = module.frontend.cloudfront_distribution_id
}

output "backend_instance_ids" {
  description = "Paste comma-separated into EC2_INSTANCE_IDS GitHub secret"
  value       = join(",", module.compute.instance_ids)
}
