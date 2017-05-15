require 'spec_helper'

describe Backend do
  describe "creation" do
    it "creates an instance with valid options" do
      expect { Backend.new(host: "127.0.0.1", port: 6379) }.not_to raise_error
    end

    it "creates an instance with valid options and password" do
      expect { Backend.new(host: "127.0.0.1", port: 6379, password: "password") }.not_to raise_error
    end

    it "does not create instance without options" do
      expect { Backend.new }.to raise_error
    end

    it "does not create an instance without host" do
      expect { Backend.new(port: 6379) }.to raise_error
    end

    it "does not create an instance without port" do
      expect { Backend.new(host: "127.0.0.1") }.to raise_error
    end
  end

  # Note: this is using live redis
  describe "rugged integration" do
    let :backend do
      Backend.new(host: "127.0.0.1", port: 6379)
    end

    it "can be passed to Rugged::Repository.bare" do
      expect { Rugged::Repository.bare('test_repository', backend: backend) }.not_to raise_error
    end

    it "can be passed to Rugged::Repository.init_at" do
      expect { Rugged::Repository.init_at('test_repository', :bare, backend: backend) }.not_to raise_error
    end

    describe "ODB" do
      let :repo do
        Rugged::Repository.bare("test_repo", backend: backend)
      end

      it "can write object" do
        expect(repo.write("Test", :blob)).to match(/^[a-f0-9]+$/)
      end

      it "can test existence" do
        oid1 = "1000000000000000000000000000000000000001"
        expect(repo.exists?(oid1)).to be_falsey

        oid2 = repo.write("Test content", :blob)
        expect(repo.exists?(oid2)).to be_truthy
      end

      it "can read back" do
        oid = repo.write("Another test content", :blob)
        object = repo.read(oid)

        expect(object.type).to eq(:blob)
        expect(object.data).to eq("Another test content")
      end

      it "can read header" do
        oid = repo.write("12345", :blob)
        header = repo.read_header(oid)

        expect(header[:type]).to eq(:blob)
        expect(header[:len]).to eq(5)
      end
    end

    describe "RefDB" do
      let :repo do
        Rugged::Repository.bare("test_repo", backend: backend)
      end

      after do
        refs = [
          "HEAD",
          "refs/heads/test",
          "refs/heads/master",
          "refs/heads/test1",
          "refs/heads/test2"
        ]

        refs.each do |ref_name|
          repo.references.delete(ref_name) if repo.references[ref_name]
        end
      end

      it "can lookup reference" do
        ref = repo.references["refs/heads/nope"]

        expect(ref).to be_nil

        oid = repo.write("Test object for reference", :blob)
        repo.references.create("refs/heads/test", oid)
        ref = repo.references["refs/heads/test"]

        expect(ref).not_to be_nil

        expect(ref.target_id).to eq(oid)
        expect(ref.type).to eq(:direct)
        expect(ref.name).to eq("refs/heads/test")
      end

      it "can lookup symbolic reference" do
        oid = repo.write("Test object for reference", :blob)
        repo.references.create("refs/heads/master", oid)
        ref = repo.references["HEAD"]

        expect(ref).not_to be_nil

        expect(ref.target.name).to eq("refs/heads/master")
        expect(ref.type).to eq(:symbolic)
        expect(ref.name).to eq("HEAD")
      end

      it "can rename a reference" do
        oid = repo.write("Test object for reference", :blob)
        ref = repo.references.create("refs/heads/test1", oid)

        new_ref = repo.references.rename(ref, "refs/heads/test2")

        expect(new_ref).not_to be_nil

        expect(new_ref.name).to eq("refs/heads/test2")
        expect(new_ref.type).to eq(:direct)
        expect(new_ref.target_id).to eq(oid)
      end

      it "can delete a reference" do
        oid = repo.write("Test object for reference", :blob)
        ref = repo.references.create("refs/heads/test", oid)

        repo.references.delete(ref)
        new_ref = repo.references["refs/heads/test"]

        expect(new_ref).to be_nil
      end

      it "iterates references" do
        oid = repo.write("Test object for reference", :blob)
        repo.references.create("refs/heads/master", oid)

        expect(repo.references).to be_a(Rugged::ReferenceCollection)

        n = 0
        repo.references.each do |ref|
          expect(ref).to be_a(Rugged::Reference)
          n += 1
        end

        expect(n).to be >= 1
      end

      it "iterates reference names" do
        oid = repo.write("Test object for reference", :blob)
        repo.references.create("refs/heads/master", oid)

        expect(repo.references).to be_a(Rugged::ReferenceCollection)

        n = 0
        repo.references.each_name do |ref|
          expect(ref).to be_a(String)
          expect(ref).to match(/^[a-zA-Z0-9\/]+$/)
          n += 1
        end

        expect(n).to be >= 1
      end

      it "iterates refs by glob" do
        refs = ["refs/heads/master", "refs/heads/test1", "refs/heads/test2"]
        exp = ["refs/heads/test1", "refs/heads/test2"]

        oid = repo.write("Test object for reference", :blob)
        refs.each { |ref| repo.references.create(ref, oid) }


        # FIXME - take whole path as glob, but only iterate direct refs (I think)
        names = repo.references.each_name("refs/heads/test*").to_a

        expect(exp).to eq(names.sort)
      end

      it "iterates ref names by glob" do
                refs = ["refs/heads/master", "refs/heads/test1", "refs/heads/test2"]
        exp = ["refs/heads/test1", "refs/heads/test2"]

        oid = repo.write("Test object for reference", :blob)
        refs.each { |ref| repo.references.create(ref, oid) }

        # FIXME - take whole path as glob, but only iterate direct refs (I think)
        names = repo.references.each("refs/heads/test*").map { |r| r.name }

        expect(exp).to eq(names.sort)
      end
    end
  end
end
