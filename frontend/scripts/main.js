import { initCanvasAnimation } from './animations/canvas.js';

document.addEventListener('DOMContentLoaded', () => {
    // 1. Initialize generic background particles
    initCanvasAnimation();

    // 2. Set up Intersection Observer for triggering infographics
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.3 // Trigger when 30% of the section is visible
    };

    const sectionObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                // Fade in the section
                entry.target.classList.add('visible');
                
                if (entry.target.id === 'point-1') {
                    // CSS animations handle the rest when .visible is added
                }

                // Stop observing once visible
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Observe all infographic sections
    document.querySelectorAll('.infographic-section').forEach(section => {
        sectionObserver.observe(section);
    });
});
