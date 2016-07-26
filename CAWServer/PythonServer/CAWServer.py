from flask import Flask, request
import MySQLdb
import random
from Crypto.Cipher import AES
import json
import base64
from PKCS7Encoder import PKCS7Encoder

app = Flask(__name__)
db = MySQLdb.connect(host="localhost", user="test", passwd="1234567", db="test", charset="utf8")
cursor = db.cursor()


def fetch_library_list():
    locations = [("hot", 6000), ("recommend", 12000), ("complete", 18000)]
    result_list = {}
    for (key, value) in locations:
        start = random.randint(1, 26392) % value
        result = fetch_pure_list(start)
        result_list[key] = result
    result_dic = {"msg": "ok",
                  "code": "200",
                  "data": result_list}
    return result_dic


def fetch_discover_list():
    start = random.randint(1, 26382)
    result_list = fetch_pure_list(start, 10)
    result_dic = {"msg": "ok",
                  "code": "200",
                  "data": result_list}
    return result_dic


def fetch_search_list(dic):
    search_type = dic["type"]
    keyword = dic["keyword"]
    if search_type == '0':
        sql = "SELECT * FROM book WHERE title like '%s%%'" % keyword
    else:
        sql = "SELECT * FROM book WHERE author like '%s%%'" % keyword
    try:
        cursor.execute(sql)
    except:
        print 'fetch_search_list error'
    data = cursor.fetchall()
    data_list = fetch_data_list(data)
    result_dic = {"msg": "ok",
                  "code": "200",
                  "data": data_list}
    return result_dic


def fetch_sort_list(dic):
    sort = dic["sort"]
    location = dic["location"]
    sql = "SELECT * FROM book WHERE sort='%s' ORDER BY bookid LIMIT %s,10" % (sort,location)
    try:
        cursor.execute(sql)
    except:
        print 'fetch_sort_list error'
    data = cursor.fetchall()
    data_list = fetch_data_list(data)
    result_dic = {"msg": "ok",
                  "code": "200",
                  "data": data_list}
    return result_dic


def fetch_section_sort_list(dic):
    start = int(dic["location"])
    data_list = fetch_pure_list(start, 10)
    result_dic = {"msg": "ok",
                  "code": "200",
                  "data": data_list}
    return result_dic


def fetch_login(dic):
    userEmail = dic["userEmail"]
    userPasswd = dic["userPasswd"]
    user_dic = fetch_user(userEmail, userPasswd)
    if user_dic is None:
        data_dic = {"loginSuccess": "NO",
                    "userId": "",
                    "userName": "",
                    "userEmail": "",
                    "userPasswd": "",
                    "userShelf": {}}
        result_dic = {"msg": "ok",
                      "code": "200",
                      "data": data_dic}
        return result_dic
    else:
        shelf_list = fetch_shelf_list(user_dic["userShelf"])
        user_dic["userShelf"] = shelf_list
        user_dic["loginSuccess"] = "YES"
        result_dic = {"msg": "ok",
                      "code": "200",
                      "data": user_dic}
        return result_dic


def fetch_collect(dic):
    method = dic["method"]
    userId = dic["userId"]
    bookId = dic["bookId"]
    if method == "add":
        result_dic = add_book(userId, bookId)
    else:
        result_dic = remove_book(userId, bookId)
    return result_dic


def fetch_user(userEmail, userPasswd):
    try:
        sql = "SELECT * FROM user WHERE userEmail='%s' and userPasswd='%s'" % (userEmail,userPasswd)
        cursor.execute(sql)
    except:
        print 'fetch_user error'
    row = cursor.fetchone()
    if row is None:
        return None
    else:
        user_dic = {}
        user_dic["userId"] = row[0]
        user_dic["userName"] = row[1]
        user_dic["userEmail"] = row[2]
        user_dic["userPasswd"] = row[3]
        user_dic["userShelf"] = row[4]
        return user_dic


def fetch_shelf_list(shelf):
    try:
        sql = "SELECT * FROM book WHERE bookid in (%s)" % shelf
        cursor.execute(sql)
    except:
        print 'fetch_shelf_list error'
    data = cursor.fetchall()
    data_list = fetch_data_list(data)
    return data_list


def add_book(user_id, book_id):
    try:
        sql = "SELECT userShelf FROM user WHERE userId='%s'" % user_id
        cursor.execute(sql)
    except:
        print 'select userShelf error'
    row = cursor.fetchone()
    user_shelf = row[0]
    new_user_shelf = user_shelf+",%s" % book_id
    result_dic = {"msg": "ok",
                  "code": "200"}
    try:
        update_sql = "UPDATE user SET userShelf='%s' WHERE userId='%s'" % (new_user_shelf, user_id)
        cursor.execute(update_sql)
        result_dic["data"] = "YES"
    except:
        print 'add userShelf error'
        result_dic["data"] = "NO"
    return result_dic


def remove_book(user_id, book_id):
    try:
        sql = "SELECT userShelf FROM user WHERE userId='%s'" % user_id
        cursor.execute(sql)
    except:
        print 'select userShelf error'
    row = cursor.fetchone()
    user_shelf = row[0]
    books = user_shelf.split(",")
    new_user_shelf = ""
    for book in books:
        if book == book_id:
            continue
        else:
            new_user_shelf = new_user_shelf + book + ","
    new_user_shelf = new_user_shelf.rstrip(',')
    result_dic = {"msg": "ok",
                  "code": "200"}
    try:
        update_sql = "UPDATE user SET userShelf='%s' WHERE userId='%s'" % (new_user_shelf, user_id)
        cursor.execute(update_sql)
        result_dic["data"] = "YES"
    except:
        print 'remove userShelf error'
        result_dic["data"] = "NO"
    return result_dic


def fetch_pure_list(start, step=9):
    try:
        sql = "SELECT * FROM book WHERE bookid >=%d and bookid< %d" % (start,start+step)
        cursor.execute(sql)
    except :
        print 'fetch_pure_list error'
    data = cursor.fetchall()
    data_list = fetch_data_list(data)
    return data_list


def fetch_data_list(data):
    data_list = []
    for row in data:
        dic = dict()
        dic["bookid"] = row[0]
        dic["sfid"] = row[1]
        dic["title"] = row[2]
        dic["rating"] = row[3]
        dic["sort"] = row[4]
        dic["status"] = row[5]
        dic["author"] = row[6]
        dic["wordcount"] = row[7]
        dic["clickcount"] = row[8]
        dic["updatetime"] = row[9]
        dic["intro"] = row[10]
        dic["tags"] = row[11]
        dic["cover"] = row[12]
        data_list.append(dic)
    return data_list


def encode_result(result):
    encoder = PKCS7Encoder()
    fs = json.dumps(result)
    fs_pad = encoder.encode(fs)
    obj = AES.new('dXi5OjprsnyjU2ZJ', AES.MODE_CBC, 'bmaZYHZuuNjeC0OH')
    cipher_text = obj.encrypt(fs_pad)
    result_str = base64.b64encode(cipher_text)
    return result_str


def decode_request(req):
    b64_str = base64.b64decode(req)
    obj = AES.new('dXi5OjprsnyjU2ZJ', AES.MODE_CBC, 'bmaZYHZuuNjeC0OH')
    decoded_result = obj.decrypt(b64_str)
    encoder = PKCS7Encoder()
    trim_result = encoder.decode(decoded_result)
    return trim_result


@app.route('/index')
def hello_index():
    result = fetch_library_list()
    encoded_result = encode_result(result)
    return encoded_result


@app.route('/discover')
def hello_discover():
    result = fetch_discover_list()
    encoded_result = encode_result(result)
    return encoded_result


@app.route('/search')
def hello_search():
    data = request.args.items()
    req = dict(data).get('req')
    decoded_req = decode_request(req)
    req_dic = json.loads(decoded_req)
    result = fetch_search_list(req_dic)
    encoded_result = encode_result(result)
    return encoded_result


@app.route('/sort')
def hello_sort():
    data = request.args.items()
    req = dict(data).get('req')
    decoded_req = decode_request(req)
    req_dic = json.loads(decoded_req)
    result = fetch_sort_list(req_dic)
    encoded_result = encode_result(result)
    return encoded_result


@app.route('/sectionSort')
def hello_section_sort():
    data = request.args.items()
    req = dict(data).get('req')
    decoded_req = decode_request(req)
    req_dic = json.loads(decoded_req)
    result = fetch_section_sort_list(req_dic)
    encoded_result = encode_result(result)
    return encoded_result


@app.route('/login')
def hello_login():
    data = request.args.items()
    req = dict(data).get('req')
    decoded_req = decode_request(req)
    req_dic = json.loads(decoded_req)
    result = fetch_login(req_dic)
    encoded_result = encode_result(result)
    return encoded_result


@app.route('/collect')
def hello_collect():
    data = request.args.items()
    req = dict(data).get('req')
    decoded_req = decode_request(req)
    req_dic = json.loads(decoded_req)
    result = fetch_collect(req_dic)
    encoded_result = encode_result(result)
    return encoded_result

if __name__ == '__main__':
    app.run('0.0.0.0')
