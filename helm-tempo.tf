
resource "time_sleep" "wait_for_kubernetes" {

    depends_on = [
        data.aws_eks_cluster.installationcluster
    ]

    create_duration = "20s"
}

resource "null_resource" "example" {
  provisioner "local-exec" {
   command    = "cat ~/.kube/config"
  }
}

resource "helm_release" "tempo" {
 
  name       = "${var.release_name}"  
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  namespace  = "prometheus"
  create_namespace = false
  version    = "1.7.2"
  timeout = 2000
  set {
    name  = "server.persistentVolume.enabled"
    value = false
  }
  set {
    name = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }
}

resource "helm_release" "otel" {
 
  name       = "opentelemetry-collector"  
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  namespace  = "prometheus"
  create_namespace = false
  version    = "0.85.0"
  timeout = 2000
  values = [
    "${path.module}/values-otel.yaml"  
  ]
}
  
