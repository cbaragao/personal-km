---
layout: default
title: Documentation
nav_order: 2
has_children: true
permalink: /docs
---

# Documentation

This section contains technical documentation, processes, and systems.

## Categories

<div class="note-container" id="doc-categories">
  <!-- Categories will be populated by JavaScript -->
</div>

<script>
  document.addEventListener('DOMContentLoaded', async () => {
    try {
      // Fetch the list of documents in this section
      const response = await fetch('/assets/data/section-docs.json');
      if (!response.ok) return;
      
      const data = await response.json();
      const container = document.getElementById('doc-categories');
      
      if (!data || data.categories.length === 0) {
        container.innerHTML = '<p>No documentation categories found</p>';
        return;
      }
      
      // Display categories
      data.categories.forEach(category => {
        const card = document.createElement('a');
        card.href = category.url;
        card.classList.add('note-card');
        
        card.innerHTML = `
          <h3>${category.title}</h3>
          <p>${category.description || ''}</p>
          <small>${category.count} document${category.count !== 1 ? 's' : ''}</small>
        `;
        
        container.appendChild(card);
      });
    } catch (error) {
      console.error('Error loading documentation categories:', error);
    }
  });
</script>
