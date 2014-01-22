require 'rubygems'
require 'mechanize'
require 'json'
#encoding: ASCII-8BIT

IDS_SIMPLE = ['name', 'type','environment','designer','itemNumber', 'custMaterials', 'careInst','metric']


def create_product_description(body)
  obj = Hash.new
  #IDS_SIMPLE.each do |id_name|
  #  obj = simple(id_name,body, obj)     
  #end 
  obj = salesArg(body, obj)

  File.open("test.json", 'w') { |f| f.write(obj.to_json) }
end

#--------------
# top
def simple(id, body, obj)
  result = body.scan(/<div id\s*="#{id}".*?>(.*?)<\/div>/m)
  result = check_on_nil(result)
  if result != false
    obj[id] = result.to_s.gsub(/\t|\n|\r/, "").force_encoding('UTF-8')
  else 
    obj[id] = ''
  end
  return obj
end

# where  подробнее
def salesArg(body, obj)
  result = body.scan(/<div id="salesArg".*?>(.*?)<a/m) 
  result = check_on_nil(result)
  if result != false
    obj["salesArg"] = result.to_s.gsub(/\t|\n|\r/, "").force_encoding('UTF-8')
  else 
    obj["salesArg"] = ''
  end
  return obj
end

=begin
<div class="colAttachment">
                    <a href="/ru/ru/manuals/vissa-somnat-matras-dla-detskoj-krovatki__AA-812291-1_pub.pdf" target="_blank">ВИССА СОМНАТ Матрас для детской кроватки</a>
                    
                      <span class="fileType">
=end


def check_on_nil(obj_tmp)
  if obj_tmp != nil  
    obj_tmp = obj_tmp.pop 
    if obj_tmp != nil  
      obj_tmp = obj_tmp.pop 
      if obj_tmp != nil
        return obj_tmp
      else
        return false
      end
    else    
      return false
    end
  else 
    return false
  end
end

# drop_down_sizes
def pdf(body, obj)
  result = body.scan(/<div id="salesArg".*?>(.*?)<a/m)
  result = check_on_nil(result)
  if result != false
    obj["salesArg"] = result.to_s.gsub(/\t|\n|\r/, "").force_encoding('UTF-8')
  else 
    obj["salesArg"] = ''
  end
  return obj
end

# цены
def price1
   
end

#размеры
def displayMeasurements
   
end


#--------------
# 

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}


a.get('http://www.ikea.com/ru/ru/catalog/products/00150184/') do |page_product|          
  create_product_description(page_product.body)
end