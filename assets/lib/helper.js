import { includes as _includes } from 'lodash'
import SparkMD5 from 'spark-md5'

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

/**
 * 计算文件的 md5
 * @param {Blob} blob 文件
 */
export async function calc_blob_md5 (blob) {
  const chunk_size = 4 * 1024 * 1024
  const chunk_count = Math.ceil(blob.size / chunk_size)
  const spark = new SparkMD5.ArrayBuffer()

  for (let idx = 0; idx < chunk_count; idx++) {
    const start = idx * chunk_size
    const end = (start + chunk_size) > blob.size ? blob.size : start + chunk_size
    const buffer = await read_blob(blob.slice(start, end))

    spark.append(buffer)
  }

  const hash = spark.end()

  spark.destroy()

  return hash
}

function read_blob (blob) {
  return new Promise(function (resolve, reject) {
    const file_reader = new FileReader()

    file_reader.onload = function (ev) {
      resolve(ev.target.result)
    }

    file_reader.onerror = function () {
      reject(new Error('读取 Blob 失败'))
    }

    file_reader.readAsArrayBuffer(blob)
  })
}
