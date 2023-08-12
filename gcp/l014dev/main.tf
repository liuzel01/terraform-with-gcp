# bucket to store website 

resource "google_storage_bucket" "website" {
  name = "l01-test-terraform"
  # name     = "example-website-by-l01"
  location = "us"
}

# make new object public 
resource "google_storage_object_access_control" "public_rule" {
  object = google_storage_bucket_object.static_site_src.name
  bucket = google_storage_bucket.website.name
  role   = "READER"
  entity = "allUsers"
}

# upload the html file to the bucket 
resource "google_storage_bucket_object" "static_site_src" {
  name   = "index.html"
  source = "./website/index.html"
  bucket = google_storage_bucket.website.name
}

# reserve a static ip address
resource "google_compute_global_address" "website_ip" {
  name = "website-lb-ip"
}

# get the managed DNS Zone 
data "google_dns_managed_zone" "gcp_coffeetime_dev" {
  provider = google
  name = "l01-test-china"
}

# add the ip to the dns 
resource "google_dns_record_set" "website" {
  name         = "website.${data.google_dns_managed_zone.gcp_coffeetime_dev.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.gcp_coffeetime_dev.name
  rrdatas      = [google_compute_global_address.website_ip.address]
}

# add the bucket as a CDN backend 
resource "google_compute_backend_bucket" "website-backend" {
  name        = "website-bucket"
  bucket_name = google_storage_bucket.website.name
  description = "Containers files needed for the website"
  enable_cdn  = true
}

# gcp url map 
resource "google_compute_url_map" "website" {
  name            = "website-url-map"
  default_service = google_compute_backend_bucket.website-backend.self_link
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.website-backend.self_link
  }
}

# gcp http proxy 

resource "google_compute_target_http_proxy" "website" {
  name    = "website-target-proxy"
  url_map = google_compute_url_map.website.self_link
}

# GCP forwarding rule 
resource "google_compute_global_forwarding_rule" "default_l01" {
  name                  = "website-forwarding-rule-l01"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.website_ip.address
  ip_protocol = "TCP"
  port_range = "80"
  target =google_compute_url_map.website.self_link 
}
