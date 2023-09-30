variable "user_uuid" {
  description = "The universally unique identifier (UUID) for a user."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.user_uuid))
    error_message = "Invalid user_uuid. It must be a valid UUID format."
  }
}