require 'HTTParty'
require 'pry'

describe HTTParty do
posted_ids=[] #creating an array containing the IDs of all ToDos posted to the url by this test for clearup later
test_url="http://lacedeamon.spartaglobal.com/todos"

  it "should POST to Todos" do
    post = HTTParty.post(test_url, query:{title: 'new toDO', due: Date.parse("1 Jan 2009")})
    posted_ids.push(post['id'])
    expect(post.message).to eq 'Created'
    expect(post.code).to eq 201
  end

  it "shouldn't be allowed to post to a specific todo" do
    post = HTTParty.post(test_url, query:{title: 'good toDO', due: Date.parse("3 Jan 2009")})
    posted_ids.push(post['id'])
    invalid_post = HTTParty.post("#{test_url}/#{post['id']}", query:{title: 'bad toDO', due: Date.parse("12 Jan 2019")})
    expect(invalid_post.message).to eq 'Method Not Allowed'
    expect(invalid_post.code).to eq 405
  end

  it "should DELETE a Todo" do
    post = HTTParty.post(test_url, query:{title: 'delete me bitch', due: Date.today})
    p1id = post["id"]
    del = HTTParty.delete("#{test_url}/#{p1id}")
    expect(del.message).to eq 'No Content'
    expect(del.code).to eq 204
  end

  it "should not be able to delete the entire collection" do
    del = HTTParty.delete(test_url)
    expect(del.message).to eq 'Method Not Allowed'
    expect(del.code).to eq 405
  end

  it "should return 200 for successful GET requests on the collection" do
    get = HTTParty.get test_url
    expect(get.code).to eq 200
    expect(get.message).to eq 'OK'
  end

  it "should GET a specific Todo by its ID" do
    post = HTTParty.post(test_url, query:{title: 'find me!', due: Date.parse("1 Jan 2009")})
    posted_ids.push(post['id'])
    get = HTTParty.get "#{test_url}/#{post['id']}"
    expect(get.code).to eq 200
    expect(get.message).to eq 'OK'
    expect(get["title"]).to eq "find me!"
  end

  it "should be able to patch an existing Todo's title" do
    post = HTTParty.post(test_url, query:{title: 'patch me!', due: Date.today})
    posted_ids.push(post['id'])
    patchtitle = HTTParty.patch("#{test_url}/#{post['id']}", query:{title: 'patched'})
    patchdate = HTTParty.patch("#{test_url}/#{post['id']}", query:{due: Date.parse("02 Feb 2020")})
    get = HTTParty.get("#{test_url}/#{post['id']}")
    expect(get['title']).to eq "patched"
    expect(get['due']).to eq "2016-11-21"
    expect(get.code).to eq 200
    expect(get.message).to eq 'OK'
  end

  it "shouldn't be able to patch an entire collection" do
    patch = HTTParty.patch(test_url, query:{title: 'patched', due: Date.parse("02 Feb 2020")})
    expect(patch.code).to eq 405
    expect(patch.message).to eq 'Method Not Allowed'
  end

  it "it should be able to run PUT requests" do
    post = HTTParty.post(test_url, query:{title: 'put meh!', due: Date.today})
    posted_ids.push(post['id'])
    put = HTTParty.put("#{test_url}/#{post['id']}", query:{title: 'get putted', due: Date.parse("20 April 2420")})
    get = HTTParty.get("#{test_url}/#{post['id']}")
    expect(get['title']).to eq 'get putted'
    expect(get.code).to eq 200
    expect(get.message).to eq "OK"
  end

  it "shouldn't be able to PUT to the collection" do
    put = HTTParty.put(test_url, query:{title: 'invalid put', due: Date.parse("20 April 2420")})
    expect(put.code).to eq 405
    expect(put.message).to eq 'Method Not Allowed'
  end

  it "should tear down after testing" do
    posted_ids.each do |id|
      del = HTTParty.delete("#{test_url}/#{id}")
      expect(del.message).to eq 'No Content'
      expect(del.code).to eq 204
    end
  end
end
