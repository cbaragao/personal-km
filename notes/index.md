---
layout: default
title: Notes
nav_order: 3
has_children: true
permalink: /notes
---

# Notes

Personal notes, ideas, and thoughts.

## Recent Notes

<div class="recent-notes" id="recent-notes">
  <!-- Recent notes will be populated by JavaScript -->
</div>

<script>
  document.addEventListener('DOMContentLoaded', async () => {
    try {
      const response = await fetch('/assets/data/recent.json');
      if (!response.ok) return;
      
      const data = await response.json();
      const container = document.getElementById('recent-notes');
      
      if (data.length === 0) {
        container.innerHTML = '<p>No notes found</p>';
        return;
      }
      
      // Filter for only notes
      const notes = data.filter(item => item.url.startsWith('/notes/'));
      
      if (notes.length === 0) {
        container.innerHTML = '<p>No notes found</p>';
        return;
      }
      
      const list = document.createElement('ul');
      notes.slice(0, 5).forEach(note => {
        const li = document.createElement('li');
        const date = new Date(note.date).toLocaleDateString();
        li.innerHTML = `<span class="date">${date}</span> <a href="${note.url}">${note.title}</a>`;
        list.appendChild(li);
      });
      
      container.appendChild(list);
    } catch (error) {
      console.error('Error loading notes:', error);
    }
  });
</script>
