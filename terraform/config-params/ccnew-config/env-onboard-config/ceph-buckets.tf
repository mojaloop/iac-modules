resource "kubernetes_manifest" "namespace" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name"      = var.env_name
    }
  }
}

resource "kubernetes_manifest" "objectbucketclaim_rook_ceph_ceph_bucket_loki" {
  manifest = {
    "apiVersion" = "objectbucket.io/v1alpha1"
    "kind"       = "ObjectBucketClaim"
    "metadata" = {
      "name"      = "${var.env_name}-loki-bucket"
      "namespace" = var.env_name
    }
    "spec" = {
      "additionalConfig" = {
        "maxObjects" = var.max_objects
        "maxSize"    = var.max_size
      }
      "bucketName"       = "${var.env_name}-loki"
      "storageClassName" = var.storage_class
    }
  }
}


resource "kubernetes_manifest" "objectbucketclaim_rook_ceph_ceph_bucket_tempo" {
  manifest = {
    "apiVersion" = "objectbucket.io/v1alpha1"
    "kind"       = "ObjectBucketClaim"
    "metadata" = {
      "name"      = "${var.env_name}-tempo-bucket"
      "namespace" = var.env_name
    }
    "spec" = {
      "additionalConfig" = {
        "maxObjects" = var.max_objects
        "maxSize"    = var.max_size
      }
      "bucketName"       = "${var.env_name}-tempo"
      "storageClassName" = var.storage_class
    }
  }
}


resource "kubernetes_manifest" "objectbucketclaim_rook_ceph_ceph_bucket_longhorn" {
  manifest = {
    "apiVersion" = "objectbucket.io/v1alpha1"
    "kind"       = "ObjectBucketClaim"
    "metadata" = {
      "name"      = "${var.env_name}-longhorn-backup-bucket"
      "namespace" = var.env_name
    }
    "spec" = {
      "additionalConfig" = {
        "maxObjects" = var.max_objects
        "maxSize"    = var.max_size
      }
      "bucketName"       = "${var.env_name}-longhorn-backup"
      "storageClassName" = var.storage_class
    }
  }
}

resource "kubernetes_manifest" "objectbucketclaim_rook_ceph_ceph_bucket_velero" {
  manifest = {
    "apiVersion" = "objectbucket.io/v1alpha1"
    "kind"       = "ObjectBucketClaim"
    "metadata" = {
      "name"      = "${var.env_name}-velero-bucket"
      "namespace" = var.env_name
    }
    "spec" = {
      "additionalConfig" = {
        "maxObjects" = var.max_objects
        "maxSize"    = var.max_size
      }
      "bucketName"       = "${var.env_name}-velero"
      "storageClassName" = var.storage_class
    }
  }
}


resource "kubernetes_manifest" "objectbucketclaim_rook_ceph_ceph_bucket_percona" {
  manifest = {
    "apiVersion" = "objectbucket.io/v1alpha1"
    "kind"       = "ObjectBucketClaim"
    "metadata" = {
      "name"      = "${var.env_name}-percona-bucket"
      "namespace" = var.env_name
    }
    "spec" = {
      "additionalConfig" = {
        "maxObjects" = var.max_objects
        "maxSize"    = var.max_size
      }
      "bucketName"       = "${var.env_name}-percona"
      "storageClassName" = var.storage_class
    }
  }
}