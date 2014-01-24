class BasicNeedPresenter
  def initialize(need, extra_fields = [])
    @need = need
    @extra_fields = extra_fields
  end

  def as_json
    {
      _response_info: {
        status: "ok"
      }
    }.merge(present)
  end

  def present
    base_fields = {
      id: @need.need_id,
      role: @need.role,
      goal: @need.goal,
      benefit: @need.benefit,
      organisation_ids: @need.organisation_ids,
      organisations: organisations,
      applies_to_all_organisations: @need.applies_to_all_organisations,
      in_scope: @need.in_scope
    }

    @extra_fields.each_with_object(base_fields) do |field_name, field_hash|
      field_hash[field_name] = @need[field_name]
    end
  end

  private
  def organisations
    @need.organisations.map {|o|
      OrganisationPresenter.new(o).present
    }
  end
end
