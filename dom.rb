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
  #obj = packageInfo(body, obj)
  #obj = packageInfo(body, obj)
  obj = breadCrumbs(body, obj)
  #obj = moreModel(body, obj)
  #obj = links(body,obj)
  
  File.open("test.json", 'w') { |f| f.write(obj.to_json) }
end

def simple(id, body, obj)
  result = body.scan(/<div id\s*="#{id}".*?>(.*?)<\/div>/m)
  if result.any?
    obj[id] = result[0][0].gsub(/\t|\n|\r/, "").force_encoding('UTF-8')
  else 
    obj[id] = ''
  end
  return obj
end

def salesArg(body, obj)
  result = body.scan(/<div id="salesArg".*?>(.*?)<a/m)
  if result.any?
    obj["salesArg"] = result[0][0].gsub(/\t|\n|\r/, "").force_encoding('UTF-8')
  else 
    obj["salesArg"] = ''
  end
  return obj
end

def pdfs(body, obj)
  result = body.scan(/<div class="colAttachment">\s+<a href="(.*?)" target="_blank"/m)
  if result.any?   
    result.each do |element|
      element = element[0].force_encoding('UTF-8')
    end
    obj["pdfs"] = result
  else 
    obj["pdfs"] = ''
  end
  return obj
end

def images(body, obj)
  result = body.scan(/"images":{"large":\[(.*?)\]/m)
  if result.any?
    result[0][0].split(/","/).each do |elemenet|
      result.push(elemenet.to_s.gsub(/\t|\n|\r|"|\\/, "").force_encoding('UTF-8'))
    end
    obj["images"] = result
  else 
    obj["images"] = ''
  end
  return obj
end

=begin
def images(body, obj)
  result = body.scan(/"images":{"large":\[(.*?)\]/m)
  arr = [] 
  if result.any?
    result[0][0].split(/","/).each do |elemenet|
      arr.push(elemenet.to_s.gsub(/\t|\n|\r|"|\\/, "").force_encoding('UTF-8'))
    end
    obj["images"] = arr
  else 
    obj["images"] = ''
  end
  return obj
end
=end

def price1(body, obj)
  result = body.scan(/<span id="price1".*?>(.*?)\./m)
  if result.any?
    obj["price1"] = result[0][0].gsub(/\D/, "").force_encoding('UTF-8')
  else 
    obj["price1"] = ''
  end
  return obj
end

def storeformatpieces(body, obj)
  result = body.scan(/<span id="storeformatpieces".*?>(.*?)<\/span>/m)
  if result.any?
    obj["storeformatpieces"] = result[0][0].gsub(/\D/, "").force_encoding('UTF-8')
  else 
    obj["storeformatpieces"] = ''
  end
  return obj
end

def related(body, obj)
  result = body.scan(/MAY_BE_COMPLETED_WITH":\[(.*?)\]/m)
  if result.any?
    obj["related"] = result[0][0].gsub(/"/, "").force_encoding('UTF-8')
  else 
    obj["related"] = ''
  end
  return obj
end

def numberOfPackages(body, obj)
  result = body.scan(/<span id="numberOfPackages">(.*?)<\/span>/m)
  if result.any?
    obj["numberOfPackages"] = result[0][0].gsub(/\D/, "").force_encoding('UTF-8')
  else 
    obj["numberOfPackages"] = ''
  end
  return obj
end

def packageInfo(body, obj)
  result = body.scan(/<span id="numberOfPackages">.*?<\/span>.*? class="texts".*?>(.*?)<\/div>/m)
  if result.any?
    obj["packageInfo"] = result[0][0].gsub(/\t|\n|\r/, "").force_encoding('UTF-8')
  else 
    obj["packageInfo"] = ''
  end
  return obj
end

#not ready
def breadCrumbs(body, obj)
  result = body.scan(/<span id="numberOfPackages">.*?<\/span>.*? class="texts".*?>(.*?)<\/div>/m)
  if result.any?
    obj["packageInfo"] = result[0][0].gsub(/\t|\n|\r/, "").force_encoding('UTF-8')
  else 
    obj["packageInfo"] = ''
  end
  return obj
end

#not ready
def moreModel(body, obj)

end

def links(body, obj)
  result = body.scan(/<div id="subDivDropDown\d".*?>(.*?)<\/select>/m)
  arr = Hash.new
  if result.any? 
    result.each do |elemenet|
      elemenet[0] = elemenet[0].gsub(/\t|\n|\r/, "").force_encoding('UTF-8')  
      name = element[0].scan(/<label id="subDivDropDownLbl".*?>(.*?)<\/label>/m)
      if name.any?
        arr["#{name}"]
      end
    end
    obj["links"] = result
  else 
    obj["links"] = ''
  end
  return obj
end

=begin
#not ready
def links(body, obj)
  result = body.scan(/<div id="subDivDropDown\d".*?>(.*?)<\/select>/m)
  arr = Hash.new
  if result.any? 
    result.each do |elemenet|
      elemenet[0] = elemenet[0].gsub(/\t|\n|\r/, "").force_encoding('UTF-8')  
      name = element[0].scan(/<label id="subDivDropDownLbl".*?>(.*?)<\/label>/m)
      if name.any?
        arr["#{name}"]
      end
    end
    obj["links"] = result
  else 
    obj["links"] = ''
  end
  return obj
end
=end

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}


a.get('http://www.ikea.com/ru/ru/catalog/products/S19836967/') do |page_product|          
  create_product_description(page_product.body)
end