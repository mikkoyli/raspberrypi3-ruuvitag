import urllib2

def internet_on():
    try:
        urllib2.urlopen('http://www.google.com/', timeout=1)
	print("Establish connection succesfull")
        return True
    except urllib2.URLError as err: 
	print("Could not establish connection")
        return False
