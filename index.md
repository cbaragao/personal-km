---
layout: home
title: GitNotes
nav_order: 1
permalink: /
---

# GitNotes

Welcome to my knowledge base. This site serves as a central repository for documentation, notes, and resources.

## Quick Navigation

{: .note-container }
- [📚 Documentation](docs/){: .note-card }
  Notes on technical subjects, processes, and systems
  
- [📝 Notes](notes/){: .note-card }
  Personal notes, ideas, and thoughts
  
- [🔍 Resources](resources/){: .note-card }
  Links, references, and external resources

## Recent Updates

<div class="recent-updates" id="recent-updates">
  <!-- Recent updates will be populated by JavaScript -->
</div>

## Tags

<div class="tag-cloud" id="tag-cloud">
  <!-- Tags will be populated by JavaScript -->
</div>

<script>
  // Function to fetch and display recent updates
  async function loadRecentUpdates() {
    try {
      const response = await fetch('assets/data/recent.json');
      if (!response.ok) return;
      
      const data = await response.json();
      const container = document.getElementById('recent-updates');
      
      if (data.length === 0) {
        container.innerHTML = '<p>No recent updates</p>';
        return;
      }
      
      const list = document.createElement('ul');
      data.slice(0, 5).forEach(item => {
        const li = document.createElement('li');
        const date = new Date(item.date).toLocaleDateString();
        li.innerHTML = `<span class="date">${date}</span> <a href="${item.url}">${item.title}</a>`;
        list.appendChild(li);
      });
      
      container.appendChild(list);
    } catch (error) {
      console.error('Error loading recent updates:', error);
    }
  }
  
  // Function to fetch and display tag cloud
  async function loadTagCloud() {
    try {
      const response = await fetch('assets/data/tags.json');
      if (!response.ok) return;
      
      const data = await response.json();
      const container = document.getElementById('tag-cloud');
      
      if (Object.keys(data).length === 0) {
        container.innerHTML = '<p>No tags available</p>';
        return;
      }
      
      Object.keys(data).sort().forEach(tag => {
        const tagLink = document.createElement('a');
        tagLink.href = `tags#${tag}`;
        tagLink.classList.add('tag');
        tagLink.textContent = `${tag} (${data[tag]})`;
        container.appendChild(tagLink);
        // Add a space for readability
        container.appendChild(document.createTextNode(' '));
      });
    } catch (error) {
      console.error('Error loading tags:', error);
    }
  }
  
  // Load data when the page loads
  document.addEventListener('DOMContentLoaded', () => {
    loadRecentUpdates();
    loadTagCloud();
  });
</script>