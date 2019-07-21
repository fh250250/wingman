import { includes as _includes } from 'lodash'

export function human_readable_bytes (bytes) {
  const SIZE_UNIT = ['B', 'KB', 'MB', 'GB']

  for (let idx = 0; idx < SIZE_UNIT.length; idx++) {
    if (bytes / Math.pow(1024, idx + 1) < 1) {
      return (bytes / Math.pow(1024, idx)).toFixed(2) + ' ' + SIZE_UNIT[idx]
    }
  }
}

export function is_image (content_type) {
  return _includes([
    'image/png',
    'image/jpeg',
    'image/gif',
  ], content_type)
}
