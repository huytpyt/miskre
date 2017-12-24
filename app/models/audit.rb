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
      hash_search = search.to_i.zero? ? search : search.to_i
      where("lower(user_type) LIKE :search OR lower(username) LIKE :search
       OR lower(action) LIKE :search
       OR lower(remote_address) LIKE :search or auditable_id = :id_search
       OR associated_id = :id_search
       OR lower(associated_type) LIKE :search
       OR lower(auditable_type) LIKE :search
       OR user_id = :id_search
       OR remote_address ILIKE :search
       OR request_uuid ILIKE :search",
        { search: "%#{search.downcase}%", id_search: search.to_i})
      .or(
        Audit.where(id: Audit.select{ |a| a.audited_changes.values.include?(hash_search)}.pluck(:id))
       )
       .or(
        Audit.where(id: Audit.select{ |a| User.find(a.user_id).email == search.to_s }.pluck(:id))
       )
    else
      scoped
    end
  end
end
