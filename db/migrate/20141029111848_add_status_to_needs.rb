class AddStatusToNeeds < Mongoid::Migration
  def self.up
    Need.all.each do |n|
      unless n.status.present?
        if n.in_scope.nil?
          n.status = NeedStatus.new(description: "proposed")
        else
          n.status = NeedStatus.new(description: "out of scope", reason: n.out_of_scope_reason)
        end
        n.save_as(name: "Need Importer")
      end
    end
  end
end
