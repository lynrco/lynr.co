require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/web'
require './lib/lynr/controller/admin'

describe Lynr::Controller::Admin do

  let(:controller) { Lynr::Controller::Admin.new }

  # Test signature encryption against transloadit fixtures
  describe "#transloadit_params_signature" do

    context "with auth_secret", :if => (Lynr::Web.config['transloadit']['auth_secret']) do

      # NOTE: This is used to test signature generation implementation
      it "generates a signature of 'fd9adec73d417c983a85608ad152d90adb94f0fd'" do
        signature = 'fd9adec73d417c983a85608ad152d90adb94f0fd'
        params = {
          auth: {
            key: Lynr::Web.config['transloadit']['auth_key'],
            expires: "2013/12/20 06:50:57+00:00"
          },
          steps: {
            thumb: {
              robot: "/image/resize",
              width: 75,
              height: 75,
              resize_strategy: "pad",
              background: "#000000"
            }
          }
        }
        expect(controller.transloadit_params_signature(params)).to eq(signature)
      end

      it "generates a signature of 'f7d45bd0ff501c3fe30418f18e9a5281ee5f0a4e'" do
        signature = 'f7d45bd0ff501c3fe30418f18e9a5281ee5f0a4e'
        params = {
          auth: {
            key: Lynr::Web.config['transloadit']['auth_key'],
            expires: "2013/12/20 06:50:57+00:00"
          },
          steps: {
            flash_encoding: {
              use: ":original",
              robot: "/video/encode",
              preset: "flash",
              width: 640,
              height: 480
            },
            extracted_thumbs: {
              use: "flash_encoding",
              robot: "/video/thumbs",
              count: 10
            },
            small: {
              use: "extracted_thumbs",
              robot: "/image/resize",
              width: "30",
              height: "30"
            }
          }
        }
        expect(controller.transloadit_params_signature(params)).to eq(signature)
      end

      it "generates a signature of '35b620e1f3a4dbea28ba0ad3d26cd3042022e8c6'" do
        signature = '35b620e1f3a4dbea28ba0ad3d26cd3042022e8c6'
        params = {
          auth: {
            key: "465844d0682711e39bcac1b6747869bc",
            expires: "2013/12/20 06:50:57+00:00"
          },
          steps: {
            store: {
              robot: "/sftp/store",
              user: "some_user",
              host: "example.org",
              path: "uploads/dir/${file.url_name}"
            }
          },
          template_id: "some_template_id"
        }
        expect(controller.transloadit_params_signature(params)).to eq(signature)
      end

    end

    context "without auth_secret", :if => (!Lynr::Web.config['transloadit']['auth_secret']) do

      it "generates nil" do
        expect(controller.transloadit_params_signature({})).to be_nil
      end

    end

  end

end
