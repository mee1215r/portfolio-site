const galleryToggle = document.getElementById('gallery-toggle');
const gallerySubNav = document.getElementById('gallery-sub-nav');

galleryToggle.addEventListener('click', (event) => {
  event.preventDefault();
  gallerySubNav.hidden = !gallerySubNav.hidden;
  galleryToggle.classList.toggle('is-open', !gallerySubNav.hidden);
});

// 写真をタップすると、大きく表示する(ライトボックス)
const lightbox = document.getElementById('lightbox');
const lightboxImg = document.getElementById('lightbox-img');
const lightboxClose = document.getElementById('lightbox-close');
const lightboxPrev = document.getElementById('lightbox-prev');
const lightboxNext = document.getElementById('lightbox-next');

const galleryImages = Array.from(document.querySelectorAll('.gallery-grid img'));
let currentIndex = -1;

function showImage(index) {
  currentIndex = (index + galleryImages.length) % galleryImages.length;
  const img = galleryImages[currentIndex];
  lightboxImg.src = img.src;
  lightboxImg.alt = img.alt;
}

function openLightbox(index) {
  showImage(index);
  lightbox.hidden = false;
}

function closeLightbox() {
  lightbox.hidden = true;
  lightboxImg.src = '';
}

galleryImages.forEach((img, index) => {
  img.addEventListener('click', () => openLightbox(index));
});

lightboxClose.addEventListener('click', closeLightbox);
lightboxPrev.addEventListener('click', () => showImage(currentIndex - 1));
lightboxNext.addEventListener('click', () => showImage(currentIndex + 1));

lightbox.addEventListener('click', (event) => {
  if (event.target === lightbox) closeLightbox();
});

document.addEventListener('keydown', (event) => {
  if (lightbox.hidden) return;
  if (event.key === 'Escape') closeLightbox();
  if (event.key === 'ArrowLeft') showImage(currentIndex - 1);
  if (event.key === 'ArrowRight') showImage(currentIndex + 1);
});
