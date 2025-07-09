---
layout: page
title: Search
nav_order: 99
permalink: /search
---

# Search

<div class="search-container">
  <input type="text" id="search-input" placeholder="Search the knowledge base...">
  <button id="search-button">Search</button>
</div>

<div class="search-results" id="search-results">
  <!-- Results will be displayed here -->
</div>

<script src="https://unpkg.com/lunr/lunr.js"></script>
<script>
  // Global variables
  let searchIndex;
  let searchData;
  
  // Load the search index when the page loads
  document.addEventListener('DOMContentLoaded', async () => {
    try {
      const response = await fetch('/assets/data/search-index.json');
      if (!response.ok) {
        throw new Error('Could not load search index');
      }
      
      const data = await response.json();
      searchData = data.documents;
      
      // Build the Lunr index
      searchIndex = lunr(function() {
        this.ref('id');
        this.field('title', { boost: 10 });
        this.field('content');
        this.field('tags', { boost: 5 });
        
        data.documents.forEach(doc => {
          this.add(doc);
        });
      });
      
      // Set up the search button
      document.getElementById('search-button').addEventListener('click', performSearch);
      
      // Set up enter key press
      document.getElementById('search-input').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
          performSearch();
        }
      });
      
      // Auto-search from URL parameters
      const urlParams = new URLSearchParams(window.location.search);
      const query = urlParams.get('q');
      if (query) {
        document.getElementById('search-input').value = query;
        performSearch();
      }
      
    } catch (error) {
      console.error('Error loading search index:', error);
      document.getElementById('search-results').innerHTML = `
        <div class="search-error">
          <p>Search index not available. Please run the generate-search-index.ps1 script to create it.</p>
        </div>
      `;
    }
  });
  
  // Perform the search
  function performSearch() {
    const query = document.getElementById('search-input').value.trim();
    const resultsContainer = document.getElementById('search-results');
    
    if (!query || query.length < 2) {
      resultsContainer.innerHTML = '<p>Please enter at least 2 characters to search</p>';
      return;
    }
    
    try {
      // Update URL with search query
      const url = new URL(window.location);
      url.searchParams.set('q', query);
      window.history.replaceState({}, '', url);
      
      // Perform the search using Lunr
      const results = searchIndex.search(query);
      
      if (results.length === 0) {
        resultsContainer.innerHTML = '<p>No results found</p>';
        return;
      }
      
      // Display results
      const resultHtml = results.map(result => {
        const doc = searchData.find(d => d.id === result.ref);
        if (!doc) return '';
        
        // Extract context around the matching terms
        let context = '';
        const contentLower = doc.content.toLowerCase();
        const queryLower = query.toLowerCase();
        const position = contentLower.indexOf(queryLower);
        
        if (position !== -1) {
          const start = Math.max(0, position - 50);
          const end = Math.min(doc.content.length, position + query.length + 50);
          context = doc.content.substring(start, end).replace(
            new RegExp(`(${query})`, 'gi'), 
            '<mark>$1</mark>'
          );
          context = `...${context}...`;
        } else {
          context = doc.content.substring(0, 100) + '...';
        }
        
        return `
          <div class="search-result">
            <h3 class="search-result-title">
              <a href="${doc.url}">${doc.title}</a>
            </h3>
            <p class="search-result-context">${context}</p>
            <p class="search-result-metadata">
              ${doc.tags ? `<span class="search-result-tags">Tags: ${doc.tags.join(', ')}</span>` : ''}
              <span class="search-result-date">Last updated: ${doc.date || 'Unknown'}</span>
            </p>
          </div>
        `;
      }).join('');
      
      resultsContainer.innerHTML = `
        <h2>Found ${results.length} result${results.length === 1 ? '' : 's'}</h2>
        ${resultHtml}
      `;
      
    } catch (error) {
      console.error('Error during search:', error);
      resultsContainer.innerHTML = '<p>An error occurred during search</p>';
    }
  }
</script>

<style>
  .search-container {
    display: flex;
    margin-bottom: 1.5rem;
  }
  
  #search-input {
    flex: 1;
    padding: 0.5rem;
    font-size: 1rem;
    border: 1px solid #ccc;
    border-radius: 4px 0 0 4px;
  }
  
  #search-button {
    padding: 0.5rem 1rem;
    background-color: #5739ce;
    color: white;
    border: none;
    border-radius: 0 4px 4px 0;
    cursor: pointer;
  }
  
  #search-button:hover {
    background-color: #4827b0;
  }
  
  .search-result {
    margin-bottom: 1.5rem;
    padding-bottom: 1.5rem;
    border-bottom: 1px solid #eee;
  }
  
  .search-result-title {
    margin-bottom: 0.25rem;
  }
  
  .search-result-context {
    margin-bottom: 0.5rem;
    color: #444;
  }
  
  .search-result-context mark {
    background-color: #ffffcc;
    padding: 0.1rem;
  }
  
  .search-result-metadata {
    font-size: 0.8rem;
    color: #666;
  }
  
  .search-result-tags {
    margin-right: 1rem;
  }
  
  .search-error {
    padding: 1rem;
    background-color: #fff3f3;
    border-left: 3px solid #ff6b6b;
  }
</style>
