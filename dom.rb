require 'rubygems'
require 'mechanize'
require 'json'
#encoding: ASCII-8BIT

IDS_SIMPLE = ['name', 'type','environment','designer','itemNumber', 'custMaterials', 'careInst', 'metric', 'goodToKnow']


def create_product_description(body)
  obj = Hash.new
  #IDS_SIMPLE.each do |id_name|
  #  obj = simple(id_name,body, obj)     
  #end 
  #obj = salesArg(body, obj)
  #obj = pdf(body, obj)
  #obj = images(body, obj)
  File.open("test.json", 'w') { |f| f.write(obj.to_json) }
end

#--------------
# top
def simple(id, body, obj)
  result = body.scan(/<div id\s*="#{id}".*?>(.*?)<\/div>/m)
  if result[0][0] != nil
    obj[id] = result[0][0].to_s.gsub(/\t|\n|\r/, "").force_encoding('UTF-8')
  else 
    obj[id] = ''
  end
  return obj
end

# where  подробнее
def salesArg(body, obj)
  result = body.scan(/<div id="salesArg".*?>(.*?)<a/m)
  if result[0][0] != nil
    obj["salesArg"] = result[0][0].to_s.gsub(/\t|\n|\r/, "").force_encoding('UTF-8')
  else 
    obj["salesArg"] = ''
  end
  return obj
end

def pdf(body, obj)
  result = body.scan(/<div class="colAttachment">\s+<a href="(.*?)" target="_blank"/m)
  arr = []
  result.each do |el|
    if el[0] != nil
      arr.push(el[0].to_s.force_encoding('UTF-8'))
    end
  end
  if arr != nil
    obj["pdf"] = arr
  else 
    obj["pdf"] = ''
  end
  return obj
end

def images(body, obj)
  result = body.scan(/"images":{"large":\[(.*?)\]/m)
  arr = [] 
  if result[0][0] != nil
    result[0][0].split(/","/).each do |img|
      arr.push(img.to_s.gsub(/\t|\n|\r|"|\\/, "").force_encoding('UTF-8'))
    end
    obj["images"] = arr
  else 
    obj["images"] = ''
  end
  return obj
end

# цены
def price1
   
end

#размеры
def displayMeasurements
   
end

def create_array_of_imgs(string)

end

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}


a.get('http://www.ikea.com/ru/ru/catalog/products/80178424/') do |page_product|          
  create_product_description(page_product.body)
end