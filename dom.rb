require 'rubygems'
require 'mechanize'
require 'json'
#encoding: ASCII-8BIT

IDS_SIMPLE = ['name', 'type', 'environment', 'designer', 'itemNumber', 'custMaterials', 'careInst', 'metric', 'goodToKnow']
FUNCTIONS = ['simple', 'salesArg', 'pdfs', 'images', 'price1', 'storeformatpieces', 'related', 'numberOfPackages', 'packageInfo']

def create_product_description(body)
  obj = Hash.new
  #IDS_SIMPLE.each do |id_name|
  #  obj = simple(id_name,body, obj)     
  #end 
  #obj = salesArg(body, obj)
  #obj = pdfs(body, obj)
  #obj = images(body, obj)
  #obj = price1(body, obj)
  #obj = storeformatpieces(body, obj)
  #obj = related(body, obj)
  #obj = numberOfPackages(body, obj)
  obj = packageInfo(body, obj)
  File.open("test.json", 'w') { |f| f.write(obj.to_json) }
end

#--------------
# top
def simple(id, body, obj)
  result = body.scan(/<div id\s*="#{id}".*?>(.*?)<\/div>/m)
  if result[0] != nil and result[0][0] != nil
    obj[id] = result[0][0].to_s.gsub(/\t|\n|\r/, "").force_encoding('UTF-8')
  else 
    obj[id] = ''
  end
  return obj
end

# where  подробнее
def salesArg(body, obj)
  result = body.scan(/<div id="salesArg".*?>(.*?)<a/m)
  if result[0] != nil and result[0][0] != nil
    obj["salesArg"] = result[0][0].to_s.gsub(/\t|\n|\r/, "").force_encoding('UTF-8')
  else 
    obj["salesArg"] = ''
  end
  return obj
end

def pdfs(body, obj)
  result = body.scan(/<div class="colAttachment">\s+<a href="(.*?)" target="_blank"/m)
  arr = []
  result.each do |el|
    if el[0] != nil
      arr.push(el[0].to_s.force_encoding('UTF-8'))
    end
  end
  if arr != nil
    obj["pdfs"] = arr
  else 
    obj["pdfs"] = ''
  end
  return obj
end

def images(body, obj)
  result = body.scan(/"images":{"large":\[(.*?)\]/m)
  arr = [] 
  if result[0] != nil and result[0][0] != nil
    result[0][0].split(/","/).each do |img|
      arr.push(img.to_s.gsub(/\t|\n|\r|"|\\/, "").force_encoding('UTF-8'))
    end
    obj["images"] = arr
  else 
    obj["images"] = ''
  end
  return obj
end

def price1(body, obj)
  result = body.scan(/<span id="price1".*?>(.*?)\./m)
  if result[0] != nil and result[0][0] != nil
    obj["price1"] = result[0][0].to_s.gsub(/\D/, "").force_encoding('UTF-8')
  else 
    obj["price1"] = ''
  end
  return obj
end


def storeformatpieces(body, obj)
  result = body.scan(/<span id="storeformatpieces".*?>(.*?)<\/span>/m)
  if result[0] != nil and result[0][0] != nil
    obj["storeformatpieces"] = result[0][0].to_s.gsub(/\D/, "").force_encoding('UTF-8')
  else 
    obj["storeformatpieces"] = ''
  end
  return obj
end

def related(body, obj)
  result = body.scan(/MAY_BE_COMPLETED_WITH":\[(.*?)\]/m)
  if result[0] != nil and result[0][0] != nil
    obj["related"] = result[0][0].to_s.gsub(/"/, "").force_encoding('UTF-8')
  else 
    obj["related"] = ''
  end
  return obj
end

def numberOfPackages(body, obj)
  result = body.scan(/<span id="numberOfPackages">(.*?)<\/span>/m)
  if result[0] != nil and result[0][0] != nil
    obj["numberOfPackages"] = result[0][0].to_s.gsub(/\D/, "").force_encoding('UTF-8')
  else 
    obj["numberOfPackages"] = ''
  end
  return obj
end

def packageInfo(body, obj)
  result = body.scan(/<div id="packageInfo">.*?<div class="texts">(.*?)<\/div>/m)
  if result[0] != nil and result[0][0] != nil
    obj["packageInfo"] = result[0][0].to_s.gsub(/\D/, "").force_encoding('UTF-8')
  else 
    obj["packageInfo"] = ''
  end
  return obj
end



a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}


a.get('http://www.ikea.com/ru/ru/catalog/products/30079365/') do |page_product|          
  create_product_description(page_product.body)
end