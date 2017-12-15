# == Schema Information
#
# Table name: audits
#
#  id              :integer          not null, primary key
#  auditable_id    :integer
#  auditable_type  :string
#  associated_id   :integer
#  associated_type :string
#  user_id         :integer
#  user_type       :string
#  username        :string
#  action          :string
#  audited_changes :text
#  version         :integer          default(0)
#  comment         :string
#  remote_address  :string
#  request_uuid    :string
#  created_at      :datetime
#
# Indexes
#
#  associated_index              (associated_id,associated_type)
#  auditable_index               (auditable_id,auditable_type)
#  index_audits_on_created_at    (created_at)
#  index_audits_on_request_uuid  (request_uuid)
#  user_index                    (user_id,user_type)
#

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
