require 'spec_helper'

describe "catalog/_index_header_default" do
  let :document do
    SolrDocument.new :id => 'xyz', :format => 'a'
  end

  let :blacklight_config do
    Blacklight::Configuration.new
  end

  before do
    assign :response, double(params: {})
    allow(view).to receive(:render_grouped_response?).and_return false
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:current_search_session).and_return nil
    allow(view).to receive(:search_session).and_return({})
  end

  it "should render the document header" do
    allow(view).to receive(:render_index_doc_actions)
    render partial: "catalog/index_header_default", locals: {document: document, document_counter: 1}
    expect(rendered).to have_selector('.document-counter', text: "2")
  end

  it "should allow the title to take the whole space if no document tools are rendered" do
    allow(view).to receive(:render_index_doc_actions)
    render partial: "catalog/index_header_default", locals: {document: document, document_counter: 1}
    expect(rendered).to have_selector '.index_title.col-md-12'
  end
  
  it "should give the document actions space if present" do
    allow(view).to receive(:render_index_doc_actions).and_return("DOCUMENT ACTIONS")
    render partial: "catalog/index_header_default", locals: {document: document, document_counter: 1}
    expect(rendered).to have_selector '.index_title.col-sm-9'
    expect(rendered).to have_content "DOCUMENT ACTIONS"
  end

end
