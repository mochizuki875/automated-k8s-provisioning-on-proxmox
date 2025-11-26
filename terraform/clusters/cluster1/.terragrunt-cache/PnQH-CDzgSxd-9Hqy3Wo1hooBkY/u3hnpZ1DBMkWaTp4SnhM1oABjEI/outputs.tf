output "vm_info" {
  description = "作成されたVMの情報"
  value = {
    for vm_name, vm in proxmox_vm_qemu.k8s_vms : vm_name => {
      id          = vm.vmid
      name        = vm.name
      node        = vm.target_node
      ip_address  = split("/", vm.ipconfig0)[0]
      ssh_command = "ssh ${var.default_user}@${split(",", split("/", vm.ipconfig0)[0])[0]}"
    }
  }
}

output "cluster_nodes" {
  description = "クラスタノード情報"
  value = {
    control_plane = [
      for vm_name, vm in proxmox_vm_qemu.k8s_vms :
      {
        name = vm.name
        ip   = split("/", split(",", vm.ipconfig0)[0])[0]
      }
      if try(var.vms[index(var.vms.*.name, vm_name)].role, "") == "ControlPlane"
    ]
    nodes = [
      for vm_name, vm in proxmox_vm_qemu.k8s_vms :
      {
        name = vm.name
        ip   = split("/", split(",", vm.ipconfig0)[0])[0]
      }
      if try(var.vms[index(var.vms.*.name, vm_name)].role, "") == "Node"
    ]
  }
}
