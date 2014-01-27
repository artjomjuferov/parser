require 'rubygems'
require 'mechanize'
require 'json'
#encoding: ASCII-8BIT

IDS_SIMPLE = ['name', 'type', 'environment', 'designer', 'itemNumber', 'custMaterials', 'careInst', 'metric', 'goodToKnow']
FUNCTIONS = ['simple', 'salesArg', 'pdfs', 'images', 'price1', 'storeformatpieces', 'related', 'numberOfPackages', 'packageInfo']

def create_product_description(body)
  obj = Hash.new
  IDS_SIMPLE.each do |id_name|
    obj = simple(id_name,body, obj)     
  end 
  obj = salesArg(body, obj)
  obj = pdfs(body, obj)
  obj = images(body, obj)
  obj = price1(body, obj)
  obj = storeformatpieces(body, obj)
  obj = related(body, obj)
  obj = numberOfPackages(body, obj)
  obj = packageInfo(body, obj)
  obj = packageInfo(body, obj)
  obj = breadCrumbs(body, obj)
  obj = links(body,obj)
  
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


def breadCrumbs(body, obj)
  result = body.scan(/<ul id="breadCrumbs">(.*?)<\/ul>/m)
  if result.any?
    tmp = result[0][0].scan(/href="\/ru\/ru\/catalog\/categories\/departments\/(.*?)\/".?>(.*?)<\/a>/m)
    p tmp
    i = 0 
    tmp.each do |el|
      i += 1
      el[1] = el[1].force_encoding('UTF-8')
      obj["breadCrumbs#{i}"] = el
    end
  end
  p obj
  return obj
end


def find_last_suitable(value, body)
  tmp = body.scan(/"partNumber"(.*?"catEntryId":"#{value}")/)
  if tmp.any?
    return find_last_suitable(value, tmp[0][0])
  else 
    return body
  end
end

def links(body, obj)
  result = body.scan(/<div id="subDivDropDown(\d)".*?>(.*?)<\/select>/m)
  if !result.any?
    return obj
  end
  i = 0 
  result.each do |element|
    links = Hash.new
    array_of_atr = []
    tmp = body.scan(/<label id="subDivDropDownLbl#{element[0]}.*?for="drop(.*?)"/m)
    if tmp.any? and element.any?
      options = element[1].scan(/<option value="(.*?)"/m)
      options.each do |option|
        option_name = element[1].scan(/<option value="#{option[0]}".*?>(.*?)<\/option>/m)
        if option_name.any?
          option_name = option_name[0][0].gsub(/\t|\n|\r/, "").force_encoding('UTF-8')  
        else
          option_name = ''
        end
        option[0].split(/;/).each do |value|
          link = Hash.new
          id = find_last_suitable(value, body).scan(/:"(.*?)","attachments"/)
          if id.any? 
            link["#{tmp[0][0].force_encoding('UTF-8')}"] = option_name 
            links["#{id[0][0]}"] = link
          end 
        end
      end
      obj["links#{i}"] = links
    end
  end
  return obj
end


#a = Mechanize.new { |agent|
#  agent.user_agent_alias = 'Mac Safari'
#}

p `ls bathroom/10555/00074185d`.empty?

#a.get('http://www.ikea.com/ru/ru/catalog/products/S29836976/') do |page_product|          
#  create_product_description(page_product.body)
#end