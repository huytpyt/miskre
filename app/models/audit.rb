class Audit < Audited::Audit
  def self.search(search)
    if search
      where("lower(user_type) LIKE :search OR lower(username) LIKE :search
       OR lower(action) LIKE :search
       OR lower(remote_address) LIKE :search", { search: "%#{search.downcase}%" })
    else
      scoped
    end
  end
end
