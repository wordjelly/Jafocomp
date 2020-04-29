class ::Hash
  def stringify_keys
      h = self.map do |k,v|
        v_str = if v.instance_of? Hash
                  v.stringify_keys
                elsif v.instance_of? Array
                  v.map{|el|
                    if el.instance_of? Hash
                      el.stringify_keys
                    else
                      el
                    end
                  }
                else
                  v
                end

        [k.to_s, v_str]
      end
      Hash[h]
  end
end