from htmldom import htmldom
import re
import requests
from bs4 import BeautifulSoup
import json

urlSample = "http://www.nettruyen.com/tim-truyen?page={}"

headers = {
    "Referer": "http://www.nettruyen.com/",
    "Origin": "http://www.nettruyen.com",
    "Host": "www.nettruyen.com"
}

manga_list = []

for i in range(1, 550):
    response = requests.get(urlSample.format(i), headers = headers)
    if(response.status_code != 200):
        continue
    else:
        response = response.text
    
    soup = BeautifulSoup(response, "html.parser")
    items = soup.find_all("div", class_="item")

    for item in items:
        description = item.find("div", class_="box_text").get_text()
        imgUrl = "http:" + item.select("div figure div a img")[0]['data-original']
        title = item.select("div.clearfix div.box_img a")[0]['title']
        url = item.select("div figure div a")[0]['href']
        ids = re.findall(r'\d+', url)
        
        id = ids[len(ids)-1]
        mainInfo = item.find("div", class_="message_main")

        reAuthor = re.findall(r'Tác giả:</label>(.*?)</p>', str(mainInfo))
        if (len(reAuthor) > 0):
            author = reAuthor[0]
        else:
            author = ""
        

        reTags = re.findall(r'Thể loại:</label>(.*?)</p>', str(mainInfo))
        if (len(reTags) > 0):
            tags = reTags[0].split(',')
            for i in range(0, len(tags)):
                tags[i] = tags[i].strip()
                if ( len(tags[i]) > 20):
                    print(str(mainInfo))
        else:
            tags = []
        
        
        reStatus = re.findall(r'Tình trạng:</label>(.*?)</p>', str(mainInfo))
        if (len(reStatus) > 0):
            status = reStatus[0]
        else:
            status = ""

        reAlias = re.findall(r'Tên khác:</label>(.*?)</p>', str(mainInfo))
        if (len(reAlias) > 0):
            alias = reAlias[0].split(',')
            for i in range(0, len(alias)):
                alias[i] = alias[i].strip()
            #print(alias)
        else:
            alias = []
        

        manga_list.append({
            "id": id,
            "url": url,
            "title": title,
            "alias": alias,
            "imgUrl": imgUrl,
            "tags": tags,
            "author": author,
            "description": description,
            "status": status,
            "lang": 'vi',
        })
    print(len(manga_list))

with open('data.json', 'w', encoding='utf-8') as f:
    json.dump(manga_list, f, ensure_ascii=False, indent=4)
