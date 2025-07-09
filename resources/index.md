---
layout: default
title: Resources
nav_order: 4
has_children: true
permalink: /resources
---

# Resources

Links, references, and external resources.

## Categories

<div class="resource-categories" id="resource-categories">
  <!-- Resource categories will be populated by JavaScript -->
</div>

<script>
  document.addEventListener('DOMContentLoaded', async () => {
    try {
      const response = await fetch('/assets/data/section-resources.json');
      if (!response.ok) return;
      
      const data = await response.json();
      const container = document.getElementById('resource-categories');
      
      if (!data || data.categories.length === 0) {
        container.innerHTML = '<p>No resource categories found</p>';
        return;
      }
      
      const grid = document.createElement('div');
      grid.classList.add('note-container');
      
      // Display categories
      data.categories.forEach(category => {
        const card = document.createElement('a');
        card.href = category.url;
        card.classList.add('note-card');
        
        card.innerHTML = `
          <h3>${category.title}</h3>
          <p>${category.description || ''}</p>
          <small>${category.count} resource${category.count !== 1 ? 's' : ''}</small>
        `;
        
        grid.appendChild(card);
      });
      
      container.appendChild(grid);
    } catch (error) {
      console.error('Error loading resource categories:', error);
    }
  });
</script>
