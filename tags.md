---
layout: default
title: Tags
nav_order: 97
permalink: /tags
---

# Tags

Browse content by tags.

<div class="tag-list" id="tag-list">
  <!-- Tags will be populated by JavaScript -->
</div>

<script>
  document.addEventListener('DOMContentLoaded', async () => {
    try {
      // Fetch tags data
      const tagsResponse = await fetch('/assets/data/tags.json');
      if (!tagsResponse.ok) throw new Error('Could not load tags data');
      const tagsData = await tagsResponse.ok ? await tagsResponse.json() : {};
      
      // Fetch search index for content data
      const indexResponse = await fetch('/assets/data/search-index.json');
      if (!indexResponse.ok) throw new Error('Could not load content data');
      const indexData = await indexResponse.json();
      
      const container = document.getElementById('tag-list');
      
      if (Object.keys(tagsData).length === 0) {
        container.innerHTML = '<p>No tags available</p>';
        return;
      }
      
      // Check if there's a hash in the URL
      const activeTag = window.location.hash.substring(1);
      
      // Create tags section
      const tagsSection = document.createElement('div');
      tagsSection.classList.add('tags-container');
      
      Object.keys(tagsData).sort().forEach(tag => {
        const tagLink = document.createElement('a');
        tagLink.href = `#${tag}`;
        tagLink.classList.add('tag');
        if (tag === activeTag) {
          tagLink.classList.add('active');
        }
        tagLink.textContent = `${tag} (${tagsData[tag]})`;
        tagLink.addEventListener('click', (e) => {
          document.querySelectorAll('.tag').forEach(t => t.classList.remove('active'));
          tagLink.classList.add('active');
          showTagContent(tag, indexData.documents);
        });
        tagsSection.appendChild(tagLink);
      });
      
      container.appendChild(tagsSection);
      
      // Create content section
      const contentSection = document.createElement('div');
      contentSection.id = 'tag-content';
      contentSection.classList.add('tag-content');
      container.appendChild(contentSection);
      
      // Show content for active tag if present
      if (activeTag && tagsData[activeTag]) {
        showTagContent(activeTag, indexData.documents);
      }
      
    } catch (error) {
      console.error('Error loading tags data:', error);
      document.getElementById('tag-list').innerHTML = '<p>Error loading tags. Please make sure the data files are generated.</p>';
    }
  });
  
  function showTagContent(tag, documents) {
    const contentSection = document.getElementById('tag-content');
    
    // Filter documents by tag
    const filteredDocs = documents.filter(doc => 
      doc.tags && doc.tags.includes(tag)
    );
    
    if (filteredDocs.length === 0) {
      contentSection.innerHTML = `<h2>Tag: ${tag}</h2><p>No content found with this tag</p>`;
      return;
    }
    
    let html = `<h2>Tag: ${tag}</h2>`;
    html += '<ul class="tag-items">';
    
    filteredDocs.forEach(doc => {
      const date = doc.date ? `<span class="date">${doc.date}</span>` : '';
      html += `
        <li>
          <a href="${doc.url}">${doc.title}</a> ${date}
        </li>
      `;
    });
    
    html += '</ul>';
    contentSection.innerHTML = html;
  }
</script>

<style>
  .tags-container {
    margin-bottom: 2rem;
  }
  
  .tag {
    display: inline-block;
    padding: 4px 8px;
    margin: 0 6px 8px 0;
    background-color: #f0f0f0;
    border-radius: 4px;
    font-size: 0.9rem;
    transition: background-color 0.2s;
  }
  
  .tag:hover {
    background-color: #e0e0e0;
    text-decoration: none;
  }
  
  .tag.active {
    background-color: #5739ce;
    color: white;
  }
  
  .tag-content h2 {
    border-bottom: 1px solid #eaeaea;
    padding-bottom: 0.5rem;
    margin-bottom: 1rem;
  }
  
  .tag-items {
    list-style-type: none;
    padding-left: 0;
  }
  
  .tag-items li {
    margin-bottom: 0.5rem;
    padding: 0.5rem;
    border-radius: 4px;
  }
  
  .tag-items li:hover {
    background-color: #f8f8f8;
  }
  
  .tag-items li .date {
    font-size: 0.8rem;
    color: #888;
    margin-left: 0.5rem;
  }
</style>
