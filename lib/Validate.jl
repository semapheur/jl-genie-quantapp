module Validate

export validate_dict, validate_records

function validate_dict(dict::Dict{String,U}, schema::Type{T}) where {U,T}
  default_instance = T()

  for field in fieldnames(schema)
    key = Symbol(field)
    key_ = String(key)
    field_type = typeof(getfield(default_instance, key))
    println(field_type)

    if !haskey(dict, key_)
      dict[key_] = default_instance.key
    else
      if !isa(dict[key_], field_type)
        dict[key_] = default_instance.key
      end
    end
  end
end

function validate_records(records::Vector{Dict{String,U}}, schema::Type{T}) where {U,T}
  validated_records = [validate_dict(record, schema) for record in records]
  return validated_records
end

end