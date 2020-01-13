local http_model = {}


function http_model:trim(s)
   return s:match'^%s*(.*%S)%s*$' or ''
end


function http_model:get_http_params(...)
    local data = {}
    for k,v in ipairs({...}) do
        for i,j in pairs(v) do
            data[i] = http_model:trim(j)
        end
    end
    return data
end


function http_model:is_empty(s)
  return s == nil or s == ''
end


--分页变量

function http_model:get_pagination(maxentries, items_per_page, params)
    local visit_page = params.visit_page or 0
    local pagination = {}
    pagination['maxentries'] = maxentries
    pagination['prev_text'] = 'Prev'
    pagination['next_text'] = 'Next'
    pagination['items_per_page'] = items_per_page
    pagination['num_display_entries'] = '6'
    pagination['current_page'] = visit_page
    pagination['visit_page'] = visit_page
    pagination['num_edge_entries'] = '5'
    return pagination
end

return http_model