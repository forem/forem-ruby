module Forem
  class AdminUser < APIResource
    extend APIOperations::Create

    OBJECT_NAME = "admin_user"
    RESOURCE_PATH = "/api/admin/users"
  end
end
