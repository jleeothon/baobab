require 'json'


text = File.read("test/breast-cancer-adapted.json")
json =  JSON.parse(text)

json2 = json.map do |i|
    {
        "age" => i[0],
        "menopause" => i[1],
        "tumor-size" => i[2],
        "inv-nodes" => i[3],
        "node-caps" => i[4],
        "deg-malig" => i[5],
        "breast" => i[6],
        "breast-quad" => i[7],
        "irradiat" => i[8],
        "Class" => i[9]
    }
end

json2 = JSON.dump(json2)

puts json2

