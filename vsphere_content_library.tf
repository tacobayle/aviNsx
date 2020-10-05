#
resource "vsphere_content_library" "library" {
  name            = "Avi Content Library"
  storage_backing = data.vsphere_datastore.datastore.id
  description     = "Avi Content Library"
}
